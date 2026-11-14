import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class ChariPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String token;
  final String orderId;
  final VoidCallback onSuccess;

  const ChariPaymentWebView({
    Key? key,
    required this.checkoutUrl,
    required this.token,
    required this.orderId,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ChariPaymentWebView> createState() => _ChariPaymentWebViewState();
}

class _ChariPaymentWebViewState extends State<ChariPaymentWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _initWebView);
  }

  Future<void> _initWebView() async {
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0x00000000));

    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          if (progress > 60 && mounted && _isLoading) {
            setState(() => _isLoading = false);
          }
        },
        onPageStarted: (url) => _checkUrl(url),
        onPageFinished: (url) {
          if (mounted && _isLoading) setState(() => _isLoading = false);
          _checkUrl(url);
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == false) return;
          if (mounted) setState(() => _isLoading = false);
        },
        onUrlChange: (change) => _checkUrl(change.url ?? ''),
      ),
    );

    if (mounted) setState(() => _controller = controller);
    await controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkUrl(String url) {
    // Adapter ces patterns aux URLs de retour réelles configurées
    // côté Chari / backend (success_url / cancel_url)
    if (url.contains('success') || url.contains('payment.succeeded')) {
      _handleSuccess();
    } else if (url.contains('fail') ||
        url.contains('decline') ||
        url.contains('cancel')) {
      _handleCancel();
    }
  }

  void _handleSuccess() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onSuccess();
    });
  }

  void _handleCancel() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cmiPayment),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleCancel,
        ),
      ),
      body: _controller == null
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFA8161F)),
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            IgnorePointer(
              child: Container(
                color: isDark
                    ? Colors.black.withOpacity(0.85)
                    : Colors.white.withOpacity(0.85),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA8161F),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}