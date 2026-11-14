import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bottomnavigation.dart';
import 'wallet_service.dart';

class AcceuilPage extends StatefulWidget {
  final String token;
  final String? organizationId;
  final VoidCallback toggleTheme;
  final Function(String) setLanguage;
  final bool isDarkMode;
  final String currentLocale;

  AcceuilPage({
    Key? key,
    required this.token,
    this.organizationId,
    required this.toggleTheme,
    required this.setLanguage,
    required this.isDarkMode,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _AcceuilPageState createState() => _AcceuilPageState();
}

class _AcceuilPageState extends State<AcceuilPage> with WidgetsBindingObserver {
  String userName = '';
  String userLastName = '';
  String userImage = '';
  String userId = '';
  Map<String, dynamic>? organizationSettings;
  Map<String, dynamic>? organizationData;
  bool isLoading = false;
  bool get isLoggedIn => widget.token.isNotEmpty;

  double _walletBalance = 0;
  bool _walletLoading = false;

  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (isLoggedIn) {
      _loadUserData();
      _fetchOrganizationSettings();
      _fetchOrganizationData();
      _loadWalletBalance();
    }
  }

  @override
  void didUpdateWidget(AcceuilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != oldWidget.currentLocale) {
      setState(() {});
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? '';
      userLastName = prefs.getString('user_last_name') ?? '';
      userImage = prefs.getString('user_image') ?? '';
      userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> _loadWalletBalance() async {
    if (!isLoggedIn) return;
    setState(() => _walletLoading = true);
    final wallet = await WalletService.getWalletInfo(widget.token);
    if (!mounted) return;
    setState(() {
      _walletBalance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
      _walletLoading = false;
    });
  }

  Future<void> _fetchOrganizationSettings() async {
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
    }
  }

  Future<Map<String, dynamic>?> _fetchOrganizationData() async {
    try {
      const String uniqueId = "dsqqqqqlkkkkljlkwwwwwww";
      final uri = Uri.parse(
          "https://quizzbackoff.ma/api/public/organisation/1")
          .replace(queryParameters: {
        'mobileApp': 'true',
        'unique_id': uniqueId,
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final orgData = data["data"] as Map<String, dynamic>;
          if (mounted) {
            setState(() => organizationData = orgData);
          }
          await _saveOrgSettingsToPrefs(orgData);
          return orgData;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveOrgSettingsToPrefs(Map<String, dynamic> orgData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('activatedcmi', orgData['activatedcmi'] == true);
    await prefs.setBool('activatedchari', orgData['activatedchari'] == true);
    await prefs.setBool(
        'ticketplaceactivated', orgData['ticketplaceactivated'] == true);
  }

  Future<bool> _isUserLoggedIn() async {
    if (!isLoggedIn) return false;
    if (userId.isEmpty) await _loadUserData();
    return userId.isNotEmpty;
  }

  Future<void> _saveLanguagePreference(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  Future<void> _handleNewsTap(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final data = await _fetchOrganizationData();
      if (data != null && data["availabilityactualite"] == true) {
        if (data["facebookPageToken"] == null ||
            data["facebookPageToken"].toString().isEmpty) {
          _showComingSoonModal(context, l10n.news);
          return;
        }
        Navigator.pushNamed(
          context,
          '/news',
          arguments: {
            'token': widget.token,
            'organizationId': widget.organizationId,
            'facebookPageId': data["facebookPageId"],
            'facebookPageToken': data["facebookPageToken"],
            'graphApiVersion': data["graphApiVersion"],
          },
        );
      } else {
        _showComingSoonModal(context, l10n.news);
      }
    } catch (e) {
      _showComingSoonModal(context, l10n.news);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleQuizTap(BuildContext context) async {
    bool logged = await _isUserLoggedIn();
    if (!logged) {
      _showLoginDialog();
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await _fetchOrganizationData();
      if (data != null && data["availability"] == true) {
        Navigator.pushNamed(
          context,
          '/wydadQuiz',
          arguments: {
            'token': widget.token,
            'organizationId': widget.organizationId
          },
        );
      } else {
        _showComingSoonModal(context, l10n.quiz);
      }
    } catch (e) {
      _showComingSoonModal(context, l10n.quiz);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleStoreTap(BuildContext context) async {
    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _fetchOrganizationSettings();

      if (organizationSettings != null &&
          organizationSettings!["enable_shop"] == 1) {
        _showStoreChoiceModal(context);
      } else {
        _showShopMaintenanceModal(context);
      }
    } catch (e) {
      _showShopMaintenanceModal(context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleTicketplaceTap(BuildContext context) async {
    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _fetchOrganizationData();

      final prefs = await SharedPreferences.getInstance();
      final activated = prefs.getBool('ticketplaceactivated') ?? false;

      if (activated) {
        Navigator.pushNamed(context, '/events', arguments: {
          'token': widget.token,
          'organizationId': widget.organizationId,
        });
      } else {
        _showComingSoonModal(context, l10n.ticketplaceLabel);
      }
    } catch (e) {
      _showComingSoonModal(context, l10n.ticketplaceLabel);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MODAL CHOIX BOUTIQUE
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
                Text(
                  l10n.chooseStore,
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
                  l10n.chooseStoreSubtitle,
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
                  subtitle: l10n.kappaSubtitle,
                  icon: Icons.checkroom,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
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
                  label: l10n.wacBrand,
                  subtitle: l10n.wacBrandSubtitle,
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
                    child: _glassButton(label: l10n.cancel),
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

  // ═══════════════════════════════════════════════════════════
  // MODALS DARK WYDAD
  // ═══════════════════════════════════════════════════════════

  void _showComingSoonModal(BuildContext context, String title) {
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
                _dialogIcon(Icons.schedule_rounded),
                const SizedBox(height: 20),
                Text(
                  title,
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
                  l10n.featureComingSoon,
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

  void _showShopMaintenanceModal(BuildContext context) {
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

  void _showLoginDialog() {
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
                _dialogIcon(Icons.lock_outline_rounded),
                const SizedBox(height: 20),
                Text(
                  l10n.loginRequired,
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
                  l10n.loginToAccessQuiz,
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
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.login,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: _glassButton(label: l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
                _dialogIcon(Icons.logout_rounded),
                const SizedBox(height: 20),
                Text(
                  l10n.logout,
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
                  l10n.logoutConfirmation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: _glassButton(label: l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await http.post(
                            Uri.parse(
                                "https://ticketing.ma/api/customer/logout"),
                            headers: {
                              "Authorization": "Bearer ${widget.token}",
                              "Content-Type": "application/json",
                            },
                          );
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        child: _gradientButton(label: l10n.logout),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS UI
  // ═══════════════════════════════════════════════════════════

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
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
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

  // ═══════════════════════════════════════════════════════════
  // LANGUAGE
  // ═══════════════════════════════════════════════════════════
  void _showLanguageMenu(BuildContext context) {
    final languages = [
      {'code': 'fr', 'countryCode': 'FR', 'label': 'FR', 'name': l10n.french},
      {'code': 'ar', 'countryCode': 'MA', 'label': 'AR', 'name': l10n.arabic},
      {'code': 'en', 'countryCode': 'GB', 'label': 'EN', 'name': l10n.english},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23030A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final selected = widget.currentLocale == lang['code'];
            return ListTile(
              leading: SizedBox(
                width: 32,
                height: 22,
                child: CountryFlag.fromCountryCode(
                  lang['countryCode'] as String,
                ),
              ),
              title: Text(
                lang['name'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
              onTap: () {
                Navigator.pop(context);
                if (lang['code'] != widget.currentLocale) {
                  _saveLanguagePreference(lang['code'] as String);
                  widget.setLanguage(lang['code'] as String);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A0710),
                  Color(0xFF23030A),
                  Color(0xFF120104),
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC8172A).withOpacity(0.55),
                      const Color(0xFFC8172A).withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.62],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildEventsHeroCard(context),
                    const SizedBox(height: 12),
                    _buildWalletCard(context),
                    const SizedBox(height: 12),
                    _buildTilesGrid(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: CustomBottomNavigation(
              currentIndex: 2,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/events', arguments: {
                      'token': widget.token,
                      'organizationId': widget.organizationId,
                    });
                    break;
                  case 1:
                    _handleStoreTap(context);
                    break;
                  case 2:
                    break;
                  case 3:
                    if (isLoggedIn) {
                      Navigator.pushNamed(context, '/editProfile',
                          arguments: {
                            'token': widget.token,
                            'toggleTheme': widget.toggleTheme,
                            'setLanguage': widget.setLanguage,
                            'isDarkMode': widget.isDarkMode,
                            'currentLocale': widget.currentLocale,
                          });
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                    break;
                }
              },
              token: widget.token,
              organizationId: widget.organizationId,
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(primary)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loading,
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                SizedBox(
                  height: 54,
                  width: 54,
                  child: Image.asset(
                    'assets/logo1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.wydadAc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showLanguageMenu(context),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.currentLocale.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                _showLogoutConfirmation(context);
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Icon(
                isLoggedIn ? Icons.power_settings_new : Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/events', arguments: {
          'token': widget.token,
          'organizationId': widget.organizationId,
        });
      },
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73000000),
              blurRadius: 50,
              offset: Offset(0, 26),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/e813ca5a1bf519b759ad1bbbedef53e3.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.15),
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD11A2A),
                        Color(0xFFA8161F),
                        Color(0xFF6E0B12)
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6E0B12).withOpacity(0.15),
                      const Color(0xFF6E0B12).withOpacity(0.55),
                      const Color(0xFF3C050A).withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                right: -40,
                top: -60,
                child: Container(
                  width: 240,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.officialTicketing,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: Colors.white.withOpacity(0.88),
                        fontFamily: 'Inter',
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.eventsTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            height: 1,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.reserveSeats,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.88),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                              ),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.reserve,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleWalletTap(context),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(
                left: -50,
                top: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD11A2A).withOpacity(0.55),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.wydadPay,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.walletTagline,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.75),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLoggedIn)
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                          ),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              l10n.activate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.balanceLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          _walletLoading
                              ? const SizedBox(
                            width: 60,
                            height: 18,
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _walletBalance
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ','),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const TextSpan(
                                  text: ' MAD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleWalletTap(BuildContext context) async {
    if (!isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    await Navigator.pushNamed(
      context,
      '/wallet',
      arguments: {
        'token': widget.token,
        'organizationId': widget.organizationId,
      },
    );
    _loadWalletBalance();
  }

  Widget _buildTilesGrid(BuildContext context) {
    final tiles = [
      {
        'title': l10n.ticketplace,
        'sub': l10n.ticketplaceSub,
        'icon': Icons.swap_horiz,
        'onTap': () => _handleTicketplaceTap(context),
      },
      {
        'title': l10n.store,
        'sub': l10n.storeSub,
        'icon': Icons.storefront_outlined,
        'onTap': () => _handleStoreTap(context),
      },
      {
        'title': l10n.news,
        'sub': l10n.newsSub,
        'icon': Icons.article_outlined,
        'onTap': () => _handleNewsTap(context),
      },
      {
        'title': l10n.fanZone,
        'sub': l10n.fanZoneSub,
        'icon': Icons.star_border,
        'onTap': () => _handleQuizTap(context),
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return GestureDetector(
          onTap: tile['onTap'] as VoidCallback,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.07),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    right: -34,
                    top: -34,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -58,
                    top: -58,
                    child: Container(
                      width: 152,
                      height: 152,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.10)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 13,
                    top: 13,
                    child: Icon(
                      tile['icon'] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tile['title'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              height: 1.2,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tile['sub'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;

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
                        border: Border.all(
                            color: Colors.white.withOpacity(0.14)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.wacBrand,
                    style: const TextStyle(
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