import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class CMIPaymentWebViewTicket extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> orderData;
  final List<MapEntry<int, int>> selectedTickets;

  const CMIPaymentWebViewTicket({
    Key? key,
    required this.amount,
    required this.orderData,
    required this.selectedTickets,
  }) : super(key: key);

  @override
  State<CMIPaymentWebViewTicket> createState() => _CMIPaymentWebViewTicketState();
}

class _CMIPaymentWebViewTicketState extends State<CMIPaymentWebViewTicket> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _initWebView();
    });
  }

  Future<void> _initWebView() async {
    final l10n = AppLocalizations.of(context);

    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0x00000000));

      controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress > 80) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            print('Page started: $url');
            _checkUrlForRedirect(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            print('Page finished: $url');
            _checkUrlForRedirect(url);
            _checkPageContent();
          },
          onWebResourceError: (error) {
            print('WebView Error: ${error.errorCode} - ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = "${l10n?.loadingError ?? 'Loading error'}: ${error.description}";
            });
          },
          onUrlChange: (change) {
            print('URL changed: ${change.url}');
            _checkUrlForRedirect(change.url ?? '');
          },
        ),
      );

      setState(() {
        _controller = controller;
      });

      _startPaymentProcess();

    } catch (e) {
      print('WebView initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "${l10n?.browserInitError ?? 'Browser initialization error'}: $e";
        _isLoading = false;
      });
    }
  }

  void _checkUrlForRedirect(String url) {
    print('Checking URL for redirect: $url');

    if (url.contains('success') ||
        url.contains('ok') ||
        url.contains('completed') ||
        url.contains('cmi/ok_page') ||
        url.contains('Retourner') ||
        url.contains('success=true') ||
        url.contains('payment=success')) {
      _handlePaymentSuccess();
    }
    else if (url.contains('fail') ||
        url.contains('cancel') ||
        url.contains('error') ||
        url.contains('cmi/failed_page') ||
        url.contains('Annuler') ||
        url.contains('success=false') ||
        url.contains('cancelled') ||
        url.contains('payment=failed')) {
      _handlePaymentCancelled();
    }
  }

  void _checkPageContent() async {
    if (_controller == null || _paymentCompleted) return;

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final pageContent = await _controller!.runJavaScriptReturningResult('document.body.innerText');
      if (pageContent != null) {
        final contentString = pageContent.toString();
        print('Page content: $contentString');
        _processPageContent(contentString);
      }

      final htmlContent = await _controller!.runJavaScriptReturningResult('document.documentElement.outerHTML');
      if (htmlContent != null) {
        final htmlString = htmlContent.toString();
        _processHtmlContent(htmlString);
      }

    } catch (e) {
      print('Error checking page content: $e');
    }
  }

  void _processPageContent(String content) {
    final l10n = AppLocalizations.of(context);

    if (_isJsonContent(content)) {
      print('Detected JSON content in page');
      _handleJsonContent(content);
      return;
    }

    if (content.contains('Annuler') && content.contains('Valider le paiement')) {
      print('Detected CMI payment page with cancel button');
      return;
    }

    if (content.contains('Order not processed') ||
        content.contains('payment failed') ||
        content.contains('transaction failed')) {
      _handlePaymentCancelled();
    }
  }

  void _processHtmlContent(String html) {
    if (html.contains('{"success":') && html.contains('"message":')) {
      print('Detected JSON in HTML');
      _extractJsonFromHtml(html);
    }
  }

  bool _isJsonContent(String content) {
    final trimmed = content.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('"') && trimmed.endsWith('"') && trimmed.contains('{')) ||
        (trimmed.contains('"success":') && trimmed.contains('"message":'));
  }

  void _extractJsonFromHtml(String html) {
    try {
      final jsonMatch = RegExp(r'\{[^{}]*(?:{[^{}]*}[^{}]*)*\}').firstMatch(html);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);
        if (jsonString != null) {
          _handleJsonContent(jsonString);
        }
      }
    } catch (e) {
      print('Error extracting JSON from HTML: $e');
    }
  }

  void _handleJsonContent(String content) {
    final l10n = AppLocalizations.of(context);

    try {
      String jsonString = content.trim();

      if (jsonString.startsWith('"') && jsonString.endsWith('"')) {
        jsonString = jsonString.substring(1, jsonString.length - 1);
      }

      jsonString = jsonString.replaceAll('\\"', '"');
      jsonString = jsonString.replaceAll('\\n', '');
      jsonString = jsonString.replaceAll('\\t', '');
      jsonString = jsonString.replaceAll('\\r', '');

      print('Cleaned JSON: $jsonString');

      final jsonResponse = jsonDecode(jsonString);

      if (jsonResponse['success'] == true) {
        _handlePaymentSuccess();
      } else {
        print('Payment failed with message: ${jsonResponse['message']}');
        _handlePaymentCancelled();
      }

    } catch (e) {
      print('Error handling JSON content: $e');
      if (content.contains('"success":false') || content.contains('Order not processed')) {
        _handlePaymentCancelled();
      }
    }
  }

  Future<void> _startPaymentProcess() async {
    final l10n = AppLocalizations.of(context);

    if (_controller == null) {
      setState(() {
        _hasError = true;
        _errorMessage = l10n?.browserNotInitialized ?? "Browser not initialized";
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final orderId = widget.orderData['order']['order_id'];
      final token = widget.orderData['token'];

      final url = "https://ticketing.ma/api/customer/payment/cmi/$orderId";

      print('Starting CMI payment for order: $orderId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "text/html,application/xhtml+xml,application/xml",
        },
      ).timeout(const Duration(seconds: 30));

      print('CMI Response Status: ${response.statusCode}');
      print('CMI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();

        if (body.startsWith('{') && body.contains('success')) {
          try {
            final jsonResponse = jsonDecode(body);
            if (jsonResponse['success'] == true) {
              _handlePaymentSuccess();
            } else {
              _handlePaymentCancelled();
            }
            return;
          } catch (e) {
            print('Error parsing JSON response: $e');
          }
        }

        if (body.startsWith("http")) {
          print('Redirecting to: $body');
          await _controller!.loadRequest(Uri.parse(body));
        }
        else if (body.contains("<html") || body.contains("<form")) {
          print('Loading HTML content');
          await _controller!.loadHtmlString(body);
        }
        else {
          try {
            final data = jsonDecode(body);
            if (data["redirect_url"] != null) {
              print('Redirecting via redirect_url: ${data["redirect_url"]}');
              await _controller!.loadRequest(Uri.parse(data["redirect_url"].toString()));
            } else {
              throw Exception(l10n?.unexpectedCmiResponse ?? "Unexpected CMI response");
            }
          } catch (e) {
            print('Fallback: loading as HTML');
            await _controller!.loadHtmlString(body);
          }
        }
      } else {
        throw Exception("${l10n?.serverError ?? 'Server error'}: ${response.statusCode}");
      }
    } catch (e) {
      print('Payment Process Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "${l10n?.paymentLoadError ?? 'Error loading payment'}: $e";
      });
    }
  }

  void _handlePaymentSuccess() {
    final l10n = AppLocalizations.of(context);
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    print('Payment successful, navigating to success page');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessPaymentScreen(
              orderId: widget.orderData['order']['order_id'],
              orderNumber: widget.orderData['order']['order_number'] ?? 'N/A',
              amount: widget.amount,
              token: widget.orderData['token'],
            ),
          ),
        );
      }
    });
  }

  void _handlePaymentCancelled() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    print('Payment cancelled, going back to previous page');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cmiPayment),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          fontFamily: 'Urbanist',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handlePaymentCancelled,
        ),
        actions: [
          if (_hasError)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startPaymentProcess,
              tooltip: l10n.retry,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startPaymentProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.initializingBrowser,
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          Container(
            color: isDarkMode ? Colors.black : Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.connectingToPaymentGateway,
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SuccessPaymentScreen extends StatelessWidget {
  final int orderId;
  final String orderNumber;
  final double amount;
  final String token;

  const SuccessPaymentScreen({
    Key? key,
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                l10n.paymentConfirmed,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                l10n.paymentProcessedSuccess,
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('${l10n.orderNumberTitle}: $orderNumber'),
                      SizedBox(height: 8),
                      Text('${l10n.orderIdTitle}: $orderId'),
                      SizedBox(height: 8),
                      Text('${l10n.amountTitle}: ${amount.toStringAsFixed(2)} MAD'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/boutique',
                      arguments: {
                        'token': token,
                      },
                    );
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}