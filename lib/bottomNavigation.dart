import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String token;
  final String? organizationId;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.token,
    this.organizationId,
  }) : super(key: key);

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  Map<String, dynamic>? organizationSettings;
  bool isLoadingBoutique = false;
  bool isLoadingWallet = false;

  final Color primary = const Color(0xFFA8161F);

  Future<void> _fetchOrganizationSettings() async {
    setState(() => isLoadingBoutique = true);
    try {
      final response = await http.get(
        Uri.parse(
            "https://ticketing.ma/api/customer/organization-setting?organization_id=20"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() => organizationSettings = data["data"]);
        }
      }
    } catch (e) {
      print("Error fetching organization settings: $e");
    } finally {
      setState(() => isLoadingBoutique = false);
    }
  }

  Future<bool> _isShopEnabled() async {
    if (organizationSettings == null) {
      await _fetchOrganizationSettings();
    }
    final settings = organizationSettings;
    if (settings == null) return false;
    final enabled = settings["enable_shop"];
    if (enabled is bool) return enabled;
    if (enabled is int) return enabled == 1;
    if (enabled is String) return enabled == "1" || enabled.toLowerCase() == "true";
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // MODAL CHOIX BOUTIQUE (identique à acceuil)
  // ═══════════════════════════════════════════════════════════
  void _showStoreChoiceModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogIcon(Icons.storefront_outlined),
                const SizedBox(height: 20),
                const Text(
                  'Choisir une boutique',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sélectionnez la boutique officielle Wydad AC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 24),
                _storeButton(
                  label: 'KAPPA',
                  subtitle: 'Boutique officielle Kappa',
                  icon: Icons.checkroom,
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    final enabled = await _isShopEnabled();
                    if (!enabled) {
                      if (mounted) _showShopMaintenanceModal(context);
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      '/boutique',
                      arguments: {
                        'token': widget.token,
                        'organizationId': widget.organizationId,
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                _storeButton(
                  label: 'WAC BRAND',
                  subtitle: 'wacofficialbrand.com',
                  icon: Icons.public,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _WacBrandWebViewPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: _glassButton(label: 'Annuler'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _storeButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        constraints: const BoxConstraints(minHeight: 68),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.55),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5E0A13), Color(0xFF2E0409)],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x80000000),
          blurRadius: 40,
          offset: Offset(0, 20),
        ),
      ],
    );
  }

  Widget _dialogIcon(IconData icon) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }

  Widget _glassButton({required String label}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _gradientButton({required String label}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showShopMaintenanceModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogIcon(Icons.build_rounded),
                const SizedBox(height: 20),
                Text(
                  l10n.comingSoon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.shopUnderMaintenance,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: _gradientButton(label: l10n.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleBoutiqueTap(BuildContext context) async {
    if (widget.token.isEmpty) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    _showStoreChoiceModal(context);
  }

  Future<void> _handleWalletTap(BuildContext context) async {
    if (widget.token.isEmpty) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() => isLoadingWallet = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => isLoadingWallet = false);
    Navigator.pushNamed(
      context,
      '/wallet',
      arguments: {
        'token': widget.token,
        'organizationId': widget.organizationId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      {'index': 2, 'icon': Icons.home_outlined, 'label': l10n.home},
      {'index': 0, 'icon': Icons.event_outlined, 'label': l10n.events},
      {'index': 1, 'icon': Icons.shopping_bag_outlined, 'label': l10n.store},
      {
        'index': -1,
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
      },
      {'index': 3, 'icon': Icons.person_outline, 'label': l10n.profile},
    ];

    return Container(
      height: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF280409).withOpacity(0.78),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: items.map((item) {
          final int index = item['index'] as int;
          final bool isSelected = index >= 0 && widget.currentIndex == index;
          final bool isLoading =
              (isLoadingBoutique && index == 1) ||
                  (isLoadingWallet && index == -1);

          return Expanded(
            child: GestureDetector(
              onTap: (isLoadingBoutique || isLoadingWallet)
                  ? null
                  : () {
                if (index == 1) {
                  _handleBoutiqueTap(context);
                } else if (index == -1) {
                  _handleWalletTap(context);
                } else {
                  widget.onTap(index);
                }
              },
              child: Container(
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? const Color(0xFFFEE15A)
                            : Colors.white.withOpacity(0.7),
                        size: 22,
                      ),
                    const SizedBox(height: 3),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFFEE15A)
                            : Colors.white.withOpacity(0.7),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WEBVIEW WAC BRAND
// ─────────────────────────────────────────────────────────────
class _WacBrandWebViewPage extends StatefulWidget {
  const _WacBrandWebViewPage({Key? key}) : super(key: key);

  @override
  State<_WacBrandWebViewPage> createState() => _WacBrandWebViewPageState();
}

class _WacBrandWebViewPageState extends State<_WacBrandWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF170205))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://wacofficialbrand.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.08),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'WAC BRAND',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA8161F),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}