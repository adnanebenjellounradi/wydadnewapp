import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:math' show Random;
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class CMIPaymentWebViewBoutique extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> orderData;
  final String orderNumber;

  const CMIPaymentWebViewBoutique({
    Key? key,
    required this.amount,
    required this.orderData,
    required this.orderNumber,
  }) : super(key: key);

  @override
  _CMIPaymentWebViewBoutiqueState createState() => _CMIPaymentWebViewBoutiqueState();
}

class _CMIPaymentWebViewBoutiqueState extends State<CMIPaymentWebViewBoutique> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _paymentCompleted = false;
  bool _successPageDetected = false;
  Timer? _checkTimer;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      // AndroidWebViewController.enableDebugging(true);
    }

    _initWebViewController();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress > 80) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrlForRedirect(url);
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            _checkUrlForRedirect(url);
            await _analyzePageContent();
            _startPeriodicCheck();
          },
          onWebResourceError: (error) {
            final l10n = AppLocalizations.of(context);
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = "${l10n?.loadingError ?? 'Loading error'}: ${error.description}";
            });
          },
          onUrlChange: (change) {
            _checkUrlForRedirect(change.url ?? '');
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPaymentProcess();
    });
  }

  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_paymentCompleted) {
        timer.cancel();
        return;
      }
      await _analyzePageContent();
    });
  }

  Future<void> _analyzePageContent() async {
    if (_paymentCompleted) return;

    try {
      final pageContent = await _controller.runJavaScriptReturningResult(
          'document.body.innerText'
      );

      if (pageContent != null) {
        final content = pageContent.toString();
        _processCMIContent(content);
      }

      final htmlContent = await _controller.runJavaScriptReturningResult(
          'document.documentElement.outerHTML'
      );

      if (htmlContent != null) {
        final html = htmlContent.toString();
        _processCMIHtml(html);
      }

    } catch (e) {
      print('Error analyzing page: $e');
    }
  }

  void _processCMIContent(String content) {
    final l10n = AppLocalizations.of(context);

    // Vérifier si c'est la page de succès CMI
    if ((content.contains('REÇU DE PAIEMENT') &&
        content.contains('Votre paiement a été accepté') &&
        content.contains('DÉTAIL DE PAIEMENT') &&
        content.contains('DÉTAIL DE LA COMMANDE')) ||
        (content.contains('Transaction réussie') ||
            content.contains('Paiement accepté') ||
            content.contains('Payment successful')) &&
            !_successPageDetected) {

      _successPageDetected = true;

      setState(() {
        _showSuccessOverlay = true;
      });
    }

    // Vérifier aussi le bouton "Retourner au site marchand"
    if (content.contains('Cliquez ici pour retourner au site marchand') && !_successPageDetected) {
      _successPageDetected = true;

      setState(() {
        _showSuccessOverlay = true;
      });

      _tryMultipleClickMethods();
    }
  }

  void _processCMIHtml(String html) {
    final l10n = AppLocalizations.of(context);

    // Rechercher des patterns spécifiques dans le HTML
    if (html.contains('name="Retourner"') ||
        html.contains('value="Retourner"') ||
        html.contains('id="Retourner"') ||
        html.contains('class="Retourner"') ||
        html.contains('name="RETOURNER"') ||
        html.contains('value="RETOURNER"') ||
        html.contains('type="submit"') && html.contains('Retourner')) {

      if (!_successPageDetected) {
        _successPageDetected = true;

        setState(() {
          _showSuccessOverlay = true;
        });

        _tryAdvancedClickMethods(html);
      }
    }
  }

  Future<void> _tryMultipleClickMethods() async {
    try {
      await _controller.runJavaScript('''
        (function() {
          var byName = document.querySelector('[name*="Retourner"], [name*="retourner"], [name*="Return"]');
          if (byName) {
            byName.click();
            return 'clicked_by_name';
          }
          
          var byValue = document.querySelector('[value*="Retourner"], [value*="retourner"], [value*="Return"]');
          if (byValue) {
            byValue.click();
            return 'clicked_by_value';
          }
          
          var buttons = document.querySelectorAll('input, button, a, div, form, span');
          for (var i = 0; i < buttons.length; i++) {
            var btn = buttons[i];
            var text = btn.innerText || btn.textContent || btn.value || btn.innerHTML || '';
            if (text.toLowerCase().includes('retourner') || text.toLowerCase().includes('return')) {
              btn.click();
              return 'clicked_by_text';
            }
          }
          
          var forms = document.getElementsByTagName('form');
          if (forms.length > 0) {
            forms[0].submit();
            return 'form_submitted';
          }
          
          return 'nothing_found';
        })();
      ''');

      await Future.delayed(Duration(milliseconds: 500));

      await _controller.runJavaScript('''
        (function() {
          var submitButtons = document.querySelectorAll('[type="submit"]');
          for (var i = 0; i < submitButtons.length; i++) {
            submitButtons[i].click();
            return 'submit_clicked';
          }
          
          var inputs = document.querySelectorAll('input');
          for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].type === 'button' || inputs[i].type === 'submit') {
              inputs[i].click();
              return 'input_clicked';
            }
          }
          
          if (window.history.length > 1) {
            window.history.back();
            return 'navigated_back';
          }
          
          return 'no_buttons';
        })();
      ''');

    } catch (e) {
      print('Error in click methods: $e');
    }
  }

  Future<void> _tryAdvancedClickMethods(String html) async {
    try {
      if (html.contains('<form')) {
        final formActionMatch = RegExp(r'<form[^>]*action="([^"]*)"').firstMatch(html);
        final formMethodMatch = RegExp(r'<form[^>]*method="([^"]*)"').firstMatch(html);

        if (formActionMatch != null) {
          await _controller.runJavaScript('''
            (function() {
              var forms = document.getElementsByTagName('form');
              if (forms.length > 0) {
                forms[0].submit();
                return true;
              }
              return false;
            })();
          ''');
        }
      }

      await _controller.runJavaScript('''
        (function() {
          if (window.onload && typeof window.onload === 'function') {
            window.onload();
          }
          
          document.dispatchEvent(new Event('DOMContentLoaded', {bubbles: true}));
          
          var scripts = document.getElementsByTagName('script');
          for (var i = 0; i < scripts.length; i++) {
            var scriptContent = scripts[i].innerText || scripts[i].textContent || '';
            if (scriptContent.includes('submit') || scriptContent.includes('click')) {
              try {
                eval(scriptContent);
              } catch(e) {
                console.log('Script execution error:', e);
              }
            }
          }
        })();
      ''');

    } catch (e) {
      print('Error in advanced click methods: $e');
    }
  }

  void _checkUrlForRedirect(String url) {
    final successPatterns = [
      'cmi/ok_page',
      'cmi/success',
      'okUrl',
      'successUrl',
      'payment_ok',
      'payment/success',
      'retour_ok',
      'callback_ok',
      'validation',
      'confirm',
      'approved',
      'accepted'
    ];

    final failurePatterns = [
      'cmi/fail_page',
      'cmi/error',
      'failUrl',
      'errorUrl',
      'payment_failed',
      'payment/error',
      'retour_nok',
      'callback_nok',
      'failed',
      'declined',
      'cancel',
      'annuler'
    ];

    for (var pattern in successPatterns) {
      if (url.contains(pattern) && !_paymentCompleted) {
        _showSuccessOverlayWithAutoRedirect();

        return;
      }
    }

    for (var pattern in failurePatterns) {
      if (url.contains(pattern) && !_paymentCompleted) {
        print('❌ Failure URL pattern detected: $pattern');
        _handlePaymentCancelled();
        return;
      }
    }

    if (url.contains('?')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final params = uri.queryParameters;

        if (params.containsKey('status') && params['status'] == 'success') {
          _showSuccessOverlayWithAutoRedirect();
          return;
        }

        if (params.containsKey('success') && params['success'] == 'true') {
          _showSuccessOverlayWithAutoRedirect();
          return;
        }

        if (params.containsKey('payment') && params['payment'] == 'success') {
          _showSuccessOverlayWithAutoRedirect();
          return;
        }

        if (params.containsKey('result') && params['result'] == 'success') {
          _showSuccessOverlayWithAutoRedirect();
          return;
        }
      }
    }
  }
  Future<void> _clearSelectedProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool removed = await prefs.remove('selectedProducts');

      if (removed) {
        print('✅ selectedProducts successfully removed from SharedPreferences');
      } else {
        print('⚠️ selectedProducts key not found or could not be removed');
      }

      // Optional: Also clear any other shopping cart related data
      await prefs.remove('cartItems'); // if you have this
      await prefs.remove('cartTotal'); // if you have this

    } catch (e) {
      print('❌ Error clearing selectedProducts: $e');
    }
  }
  void _showSuccessOverlayWithAutoRedirect() {
    if (_paymentCompleted) return;

    _successPageDetected = true;

    setState(() {
      _showSuccessOverlay = true;
    });

    // Remove selectedProducts from SharedPreferences
    _clearSelectedProducts();
  }


  Future<void> _startPaymentProcess() async {
    final l10n = AppLocalizations.of(context);

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final orderId = widget.orderData['order']['order_id'];
      final token = widget.orderData['token'];

      final url = "https://ticketing.ma/api/customer/store/payment/cmi/$orderId";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "text/html,application/xhtml+xml,application/xml",
          "User-Agent": "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36"
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = response.body;

        if (body.trim().startsWith('{')) {
          try {
            final jsonData = jsonDecode(body);
            if (jsonData['success'] == true) {
              _showSuccessOverlayWithAutoRedirect();
              return;
            } else if (jsonData['redirect_url'] != null) {
              final redirectUrl = jsonData['redirect_url'].toString();
              print('Loading redirect URL: $redirectUrl');
              await _controller.loadRequest(
                Uri.parse(redirectUrl),
                headers: {
                  'Accept': 'text/html,application/xhtml+xml,application/xml',
                  'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
                },
              );
              return;
            }
          } catch (e) {
            print('JSON parsing error: $e');
          }
        }

        await _controller.loadHtmlString('''
          <!DOCTYPE html>
          <html lang="fr">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>${l10n?.cmiPayment ?? 'Paiement CMI'}</title>
            <style>
              body { 
                font-family: Arial, sans-serif; 
                margin: 0; 
                padding: 20px; 
                background: #f5f5f5; 
              }
              .container { 
                max-width: 800px; 
                margin: 0 auto; 
                background: white; 
                padding: 20px; 
                border-radius: 10px; 
                box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
              }
              button, input[type="submit"], input[type="button"] {
                padding: 10px 20px;
                background: #4CAF50;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 16px;
              }
              button:hover, input[type="submit"]:hover, input[type="button"]:hover {
                background: #45a049;
              }
            </style>
          </head>
          <body>
            <div class="container">
              $body
            </div>
          </body>
          </html>
        ''');

      } else {
        throw Exception("${l10n?.serverError ?? 'Server error'}: ${response.statusCode}");
      }

    } catch (e) {
      print('Payment Process Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "${l10n?.error ?? 'Error'}: ${e.toString()}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToBoutique() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    _checkTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/boutique',
              (route) => false,
          arguments: {
            'token': widget.orderData['token'],
            'organizationId': widget.orderData['organizationId'],
            'refreshCart': true, // ← AJOUTEZ CETTE LIGNE
          },
        );
      }
    });
  }

  void _handlePaymentCancelled() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    _checkTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context, 'cancelled');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: _handlePaymentCancelled,
        ),
        title: Text(
          l10n.cmiPayment,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE41E26)),
                    SizedBox(height: 16),
                    Text(
                      l10n.connectingToPaymentGateway,
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          if (_showSuccessOverlay && !_paymentCompleted)
            _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  l10n.paymentSuccessful,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  l10n.paymentAcceptedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  l10n.continueShoppingMessage,
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToBoutique,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE41E26),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Color(0xFFE41E26).withOpacity(0.3),
                    ),
                    child: Text(
                      l10n.visitStore,
                      style: TextStyle(
                        fontFamily: "Urbanist",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showSuccessOverlay = false;
                    });
                  },
                  child: Text(
                    l10n.close,
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}