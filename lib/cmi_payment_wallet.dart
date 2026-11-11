import 'package:flutter/material.dart';
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

  static const String _returnUrlBase = 'https://ticketing.ma/api/customer/wallet/return';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _initWebView);
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
            if (progress > 60 && mounted && _isLoading) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (url) {
            // On ne remet PAS _isLoading = true ici pour éviter que l'overlay
            // ne revienne bloquer l'écran lors des redirections internes (3DS).
            _checkUrlForRedirect(url);
          },
          onPageFinished: (url) async {
            if (mounted && _isLoading) setState(() => _isLoading = false);
            _checkUrlForRedirect(url);
            _checkPageContent();

            // ✅ Injection du correctif d'affichage et de focus
            await _injectMobileFix(controller);
          },
          onWebResourceError: (error) {
            // Ignore les erreurs de sous-ressources (images, pubs, etc.)
            if (error.isForMainFrame == false) return;
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = "${l10n?.loadingError ?? 'Loading error'}: ${error.description}";
              });
            }
          },
          onUrlChange: (change) => _checkUrlForRedirect(change.url ?? ''),
        ),
      );

      if (mounted) setState(() => _controller = controller);
      await controller.loadRequest(Uri.parse(widget.redirectUrl));
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "${l10n?.browserInitError ?? 'Browser init error'}: $e";
          _isLoading = false;
        });
      }
    }
  }

  // ✅ CORRECTIF : Force l'affichage mobile et le clavier
  Future<void> _injectMobileFix(WebViewController controller) async {
    try {
      await controller.runJavaScript(r'''
        (function() {
          // 1. Force le viewport pour mobile (corrige l'écran tronqué)
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
          document.getElementsByTagName('head')[0].appendChild(meta);

          // 2. Force le corps à prendre 100% de la largeur
          document.body.style.width = '100%';
          document.body.style.margin = '0';
          document.body.style.padding = '0';
          document.body.style.overflowX = 'hidden';

          // 3. Force le focus et agrandit la police des inputs
          document.querySelectorAll('input').forEach(function(input) {
            input.addEventListener('touchstart', function() { this.focus(); });
            input.addEventListener('click', function() { this.focus(); });
            input.style.fontSize = '16px'; // Empêche le zoom automatique
          });
        })();
      ''');
    } catch (e) {
      print("Erreur injection JS: $e");
    }
  }

  // ✅ CORRECTIF : Détection stricte de l'URL de retour
  void _checkUrlForRedirect(String url) {
    if (!url.startsWith(_returnUrlBase)) return;

    if (url.contains('success')) {
      _handlePaymentSuccess();
    } else {
      _handlePaymentCancelled();
    }
  }

  void _checkPageContent() async {
    if (_controller == null || _paymentCompleted) return;
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final result = await _controller!.runJavaScriptReturningResult('document.body.innerText');
      final content = result.toString();

      if (content.contains('"success":true')) {
        _handlePaymentSuccess();
      } else if (content.contains('"success":false') || content.contains('Order not processed')) {
        _handlePaymentCancelled();
      }
    } catch (_) {}
  }

  void _handlePaymentSuccess() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _WalletRechargeSuccess(
            amount: widget.amount,
            reference: widget.reference,
          ),
        ),
      );
    });
  }

  void _handlePaymentCancelled() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
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
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
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
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFA8161F)),
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
          // ✅ CORRECTIF : IgnorePointer permet de cliquer à travers le loader
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

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
                _isLoading = true;
              });
              _initWebView();
            },
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
                  child: const Icon(Icons.check,
                      color: Color(0xFFF5CD52), size: 32),
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
                      const Text(
                        'Référence',
                        style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Inter',
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        reference,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/wallet', (r) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFA8161F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Retour au Wallet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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