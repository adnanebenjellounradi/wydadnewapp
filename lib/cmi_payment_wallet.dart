import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class CMIPaymentWebViewWallet extends StatefulWidget {
  final double amount;
  final String token;
  final int rechargeId;
  final String reference;
  final String redirectUrl;

  const CMIPaymentWebViewWallet({
    Key? key,
    required this.amount,
    required this.token,
    required this.rechargeId,
    required this.reference,
    required this.redirectUrl,
  }) : super(key: key);

  @override
  State<CMIPaymentWebViewWallet> createState() => _CMIPaymentWebViewWalletState();
}

class _CMIPaymentWebViewWalletState extends State<CMIPaymentWebViewWallet> {
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
            if (progress > 80 && mounted) setState(() => _isLoading = false);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            print('Page started: $url');
            _checkUrlForRedirect(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            print('Page finished: $url');
            _checkUrlForRedirect(url);
            _checkPageContent();
          },
          onWebResourceError: (error) {
            print('WebView Error: ${error.errorCode} - ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = "${l10n?.loadingError ?? 'Loading error'}: ${error.description}";
              });
            }
          },
          onUrlChange: (change) {
            print('URL changed: ${change.url}');
            _checkUrlForRedirect(change.url ?? '');
          },
        ),
      );

      if (mounted) setState(() => _controller = controller);

      // Charge l'URL CMI reçue de l'API
      await _controller!.loadRequest(Uri.parse(widget.redirectUrl));

    } catch (e) {
      print('WebView initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "${l10n?.browserInitError ?? 'Browser init error'}: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _checkUrlForRedirect(String url) {
    if (url.contains('success') || url.contains('ok_page') || url.contains('payment=success')) {
      _handlePaymentSuccess();
    } else if (url.contains('fail') || url.contains('failed_page') || url.contains('cancel') || url.contains('error')) {
      _handlePaymentCancelled();
    }
  }

  void _checkPageContent() async {
    if (_controller == null || _paymentCompleted) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final pageContent = await _controller!.runJavaScriptReturningResult('document.body.innerText');
      if (pageContent != null) {
        final content = pageContent.toString();
        if (content.contains('"success":true')) {
          _handlePaymentSuccess();
        } else if (content.contains('"success":false') || content.contains('Order not processed')) {
          _handlePaymentCancelled();
        }
      }
    } catch (e) {
      print('Error checking page content: $e');
    }
  }

  void _handlePaymentSuccess() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => _WalletRechargeSuccess(
              amount: widget.amount,
              reference: widget.reference,
            ),
          ),
        );
      }
    });
  }

  void _handlePaymentCancelled() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
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
          fontFamily: 'Inter',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handlePaymentCancelled,
        ),
      ),
      body: _hasError
          ? _buildError(l10n)
          : _controller == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA8161F)))
          : Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFA8161F)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initWebView,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _WalletRechargeSuccess extends StatelessWidget {
  final double amount;
  final String reference;
  const _WalletRechargeSuccess({required this.amount, required this.reference});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5CD52).withOpacity(0.14),
                  ),
                  child: const Icon(Icons.check, color: Color(0xFFF5CD52), size: 32),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Recharge effectuée',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+${amount.toStringAsFixed(0)},00',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5CD52),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'MAD',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Référence', style: TextStyle(color: Colors.white60, fontFamily: 'Inter', fontSize: 11)),
                      Text(reference, style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/wallet', (r) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFA8161F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retour au Wallet', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
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