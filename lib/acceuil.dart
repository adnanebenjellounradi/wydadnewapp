import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'bottomnavigation.dart';
import 'wallet_service.dart';

const String kMediaBase = 'https://quizzbackoff.ma';

String mediaUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  final s = path.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  return '$kMediaBase$s';
}

// ─── Palette maquette ─────────────────────────────────────────
const _bgTop = Color(0xFF4A0710);
const _bgMid = Color(0xFF23030A);
const _bgBot = Color(0xFF120104);
const _yellow = Color(0xFFFEE15A);
const _gold = Color(0xFFFFC97A);
const _redAccent = Color(0xFFA8161F);
const _ink = Color(0xFF120104);

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

  bool _isUnderMaintenance = false;
  bool _shouldUpdateVersion = false;
  String? _versionRequired;
  String _currentAppVersion = '';
  bool _isSupportActivated = true;

  // Events (2 derniers events, issus de l'API ticketing)
  List<Map<String, dynamic>> _homeEvents = [];

  // Actus
  String? _firstActuTitle;
  String? _firstActuImage;
  String? _firstActuUrlBtn;
  String? _secondActuTitle;
  String? _secondActuImage;
  String? _secondActuUrlBtn;

  bool _initialOrgCheckDone = false;

  final Color primary = const Color(0xFFA8161F);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  /// S'il y a au moins un event → slider events en hero.
  /// Sinon → hero actu.
  bool get _showEventsFirst => _homeEvents.isNotEmpty;

  bool get _hasFirstActu =>
      (_firstActuTitle?.trim().isNotEmpty ?? false) ||
          (_firstActuImage?.trim().isNotEmpty ?? false);

  bool get _hasSecondActu =>
      (_secondActuTitle?.trim().isNotEmpty ?? false) ||
          (_secondActuImage?.trim().isNotEmpty ?? false);

  bool get _hasAnyActu => _hasFirstActu || _hasSecondActu;

  /// Liste des actus à afficher dans le swiper (url vide si l'API n'en renvoie pas)
  List<Map<String, String>> get _actuItems {
    final items = <Map<String, String>>[];
    if (_hasFirstActu) {
      items.add({
        'title': _firstActuTitle ?? '',
        'image': _firstActuImage ?? '',
        'url': (_firstActuUrlBtn ?? '').trim(),
      });
    }
    if (_hasSecondActu) {
      items.add({
        'title': _secondActuTitle ?? '',
        'image': _secondActuImage ?? '',
        'url': (_secondActuUrlBtn ?? '').trim(),
      });
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentAppVersion = packageInfo.version;
    } catch (_) {
      _currentAppVersion = '';
    }

    await _fetchOrganizationData();
    if (!mounted) return;
    setState(() => _initialOrgCheckDone = true);

    if (!_isBlocked) {
      _fetchHomeEvents();
      if (isLoggedIn) {
        _loadUserData();
        _fetchOrganizationSettings();
        _loadWalletBalance();
      }
    }
  }

  bool get _isBlocked => _isUnderMaintenance || _isUpdateRequired;

  bool get _isUpdateRequired {
    if (!_shouldUpdateVersion) return false;
    if (_versionRequired == null || _versionRequired!.trim().isEmpty) return true;
    return _normalizeVersion(_currentAppVersion) !=
        _normalizeVersion(_versionRequired!);
  }

  String _normalizeVersion(String v) =>
      v.trim().toLowerCase().replaceFirst(RegExp(r'^v'), '');

  @override
  void didUpdateWidget(AcceuilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != oldWidget.currentLocale) setState(() {});
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
        Uri.parse("https://ticketing.ma/api/customer/organization-setting?organization_id=20"),
        headers: {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && mounted) {
          setState(() => organizationSettings = data["data"]);
        }
      }
    } catch (e) {
      print("Error fetching organization settings: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EVENTS (slider accueil)
  // ═══════════════════════════════════════════════════════════

  /// Récupère les events et garde les 2 à afficher dans le slider.
  Future<void> _fetchHomeEvents() async {
    try {
      final response = await http.get(
        Uri.parse("https://ticketing.ma/api/customer/events?offset=0&limit=20&organization_id=20"),
        headers: isLoggedIn
            ? {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"}
            : {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && mounted) {
          final raw = (data["data"] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          setState(() => _homeEvents = _pickHomeEvents(raw));
        }
      }
    } catch (e) {
      print("Error fetching home events: $e");
    }
  }

  /// Choix des 2 events : d'abord les prochains (du plus proche au plus lointain),
  /// puis, s'il en manque, les plus récents déjà passés.
  /// 👉 Pour changer la règle (ex: 2 derniers de la liste API), modifier uniquement cette méthode.
  List<Map<String, dynamic>> _pickHomeEvents(List<Map<String, dynamic>> all) {
    final now = DateTime.now();
    final withDate = all.where((e) => DateTime.tryParse(e['date']?.toString() ?? '') != null).toList();
    DateTime d(Map<String, dynamic> e) => DateTime.parse(e['date'].toString());

    final upcoming = withDate.where((e) => d(e).isAfter(now)).toList()
      ..sort((a, b) => d(a).compareTo(d(b)));
    final past = withDate.where((e) => !d(e).isAfter(now)).toList()
      ..sort((a, b) => d(b).compareTo(d(a)));

    return [...upcoming, ...past].take(2).toList();
  }

  /// Redirige directement vers l'event ciblé
  void _openEvent(Map<String, dynamic> event) {
    if (!isLoggedIn) {
      _showLoginDialog(message: l10n.loginToAccess);
      return;
    }
    Navigator.pushNamed(context, '/acheterTicketInEvent', arguments: {
      'token': widget.token,
      'eventId': event['id'],
      'organizationId': widget.organizationId,
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ORGANISATION
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> _fetchOrganizationData() async {
    try {
      const String uniqueId = "dsqqqqqlkkkkljlkwwwwwww";
      final uri = Uri.parse("https://quizzbackoff.ma/api/public/organisation/5")
          .replace(queryParameters: {'mobileApp': 'true', 'unique_id': uniqueId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final orgData = data["data"] as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              organizationData = orgData;

              _isUnderMaintenance = orgData['isUndermaintenance'] == true;
              _shouldUpdateVersion = orgData['shouldUpdateVersion'] == true;
              _versionRequired = orgData['versionrequired']?.toString();
              _isSupportActivated = orgData['isactivatedsupport'] == true;

              _firstActuTitle = orgData['firstactualitetitle']?.toString();
              _firstActuImage = mediaUrl(orgData['firstactualiteimage']?.toString());
              _firstActuUrlBtn = orgData['firstactualiteurlbtn']?.toString();

              _secondActuTitle = orgData['secondactualitetitle']?.toString();
              _secondActuImage = mediaUrl(orgData['secondactualiteimage']?.toString());
              _secondActuUrlBtn = (orgData['secondactualiteurlbtn'] ?? orgData['secondactualiteurlbutton'])?.toString();
            });
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
    await prefs.setBool('ticketplaceactivated', orgData['ticketplaceactivated'] == true);
    await prefs.setBool('isUndermaintenance', orgData['isUndermaintenance'] == true);
    await prefs.setBool('shouldUpdateVersion', orgData['shouldUpdateVersion'] == true);
    if (orgData['versionrequired'] != null) {
      await prefs.setString('versionrequired', orgData['versionrequired'].toString());
    }
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
        if (data["facebookPageToken"] == null || data["facebookPageToken"].toString().isEmpty) {
          _showComingSoonModal(context, l10n.news);
          return;
        }
        Navigator.pushNamed(context, '/news', arguments: {
          'token': widget.token,
          'organizationId': widget.organizationId,
          'facebookPageId': data["facebookPageId"],
          'facebookPageToken': data["facebookPageToken"],
          'graphApiVersion': data["graphApiVersion"],
        });
      } else {
        _showComingSoonModal(context, l10n.news);
      }
    } catch (e) {
      _showComingSoonModal(context, l10n.news);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleQuizTap(BuildContext context) async {
    bool logged = await _isUserLoggedIn();
    if (!logged) { _showLoginDialog(); return; }
    setState(() => isLoading = true);
    try {
      final data = await _fetchOrganizationData();
      if (data != null && data["availability"] == true) {
        Navigator.pushNamed(context, '/wydadQuiz', arguments: {
          'token': widget.token,
          'organizationId': widget.organizationId
        });
      } else {
        _showComingSoonModal(context, l10n.quiz);
      }
    } catch (e) {
      _showComingSoonModal(context, l10n.quiz);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Store : redirige directement vers /boutique (plus de modal Kappa / WAC Brand).
  /// Le contrôle `enable_shop` est conservé pour afficher la maintenance si la boutique est fermée.
  Future<void> _handleStoreTap(BuildContext context) async {
    if (!isLoggedIn) { Navigator.pushNamed(context, '/login'); return; }
    setState(() => isLoading = true);
    try {
      await _fetchOrganizationSettings();
      if (!mounted) return;
      if (organizationSettings != null && organizationSettings!["enable_shop"] == 1) {
        Navigator.pushNamed(context, '/boutique', arguments: {
          'token': widget.token,
          'organizationId': widget.organizationId,
        });
      } else {
        _showShopMaintenanceModal(context);
      }
    } catch (e) {
      if (mounted) _showShopMaintenanceModal(context);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleTicketplaceTap(BuildContext context) async {
    if (!isLoggedIn) { Navigator.pushNamed(context, '/login'); return; }
    setState(() => isLoading = true);
    try {
      await _fetchOrganizationData();
      final prefs = await SharedPreferences.getInstance();
      final activated = prefs.getBool('ticketplaceactivated') ?? false;
      if (activated) {
        // Redirige vers TicketplaceEventsScreen (même route que l'onglet Ticketplace de EventsPage)
        Navigator.pushNamed(context, '/ticketplace', arguments: {
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
  // MAINTENANCE / UPDATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildMaintenanceFullScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _bgBot,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgTop, _bgMid, _bgBot],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogIcon(Icons.build_circle_outlined),
                    const SizedBox(height: 28),
                    Text(l10n.maintenanceTitle, textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'urbanist', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 14),
                    Text(l10n.maintenanceMessage, textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'urbanist', fontSize: 14, height: 1.5, color: Colors.white.withOpacity(0.75))),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => isLoading = true);
                          await _fetchOrganizationData();
                          if (!mounted) return;
                          setState(() => isLoading = false);
                        },
                        child: _gradientButton(label: l10n.retry),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateFullScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _bgBot,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgTop, _bgMid, _bgBot],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogIcon(Icons.system_update_rounded),
                    const SizedBox(height: 28),
                    Text(l10n.updateRequiredTitle, textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'urbanist', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 14),
                    Text(l10n.updateRequiredMessage, textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'urbanist', fontSize: 14, height: 1.5, color: Colors.white.withOpacity(0.75))),
                    const SizedBox(height: 10),
                    Text('Version actuelle: $_currentAppVersion  •  Requise: ${_versionRequired ?? "-"}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'urbanist', fontSize: 12, color: Colors.white.withOpacity(0.55))),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updateOpenStore)));
                        },
                        child: _gradientButton(label: l10n.updateNow),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MODALS
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
                Text(title, textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'urbanist', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 10),
                Text(l10n.featureComingSoon, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'urbanist', fontSize: 13, height: 1.45, color: Colors.white.withOpacity(0.75))),
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
                Text(l10n.comingSoon, textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'urbanist', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 10),
                Text(l10n.shopUnderMaintenance, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'urbanist', fontSize: 13, height: 1.45, color: Colors.white.withOpacity(0.75))),
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

  void _showSupportUnavailableModal(BuildContext context) {
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
                _dialogIcon(Icons.support_agent),
                const SizedBox(height: 20),
                Text(l10n.supportUnavailableTitle, textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'urbanist', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 10),
                Text(l10n.supportUnavailableMessage, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'urbanist', fontSize: 13, height: 1.45, color: Colors.white.withOpacity(0.75))),
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

  void _showLoginDialog({String? message}) {
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
                Text(l10n.loginRequired, textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'urbanist', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 10),
                Text(message ?? l10n.loginToAccessQuiz, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'urbanist', fontSize: 13, height: 1.45, color: Colors.white.withOpacity(0.75))),
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
                        gradient: const LinearGradient(colors: [Color(0xFFD11A2A), _redAccent]),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.login, style: const TextStyle(fontFamily: 'urbanist', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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
                Text(l10n.logout, textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'urbanist', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 10),
                Text(l10n.logoutConfirmation, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'urbanist', fontSize: 13, height: 1.45, color: Colors.white.withOpacity(0.75))),
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
                            Uri.parse("https://ticketing.ma/api/customer/logout"),
                            headers: {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"},
                          );
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Image d'arrière-plan depuis les assets, plein cadre
  Widget _assetBg(String path, {Alignment alignment = Alignment.center}) {
    return Positioned.fill(
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        alignment: alignment,
        errorBuilder: (_, __, ___) => Container(color: _bgMid),
      ),
    );
  }

  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF5E0A13), Color(0xFF2E0409)],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.16)),
      boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 20))],
    );
  }

  Widget _dialogIcon(IconData icon) {
    return Container(
      width: 68, height: 68,
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
        child: Text(label, style: TextStyle(fontFamily: 'urbanist', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
      ),
    );
  }

  Widget _gradientButton({required String label}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFFD11A2A), _redAccent]),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontFamily: 'urbanist', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  void _showLanguageMenu(BuildContext context) {
    final languages = [
      {'code': 'fr', 'countryCode': 'FR', 'name': l10n.french},
      {'code': 'ar', 'countryCode': 'MA', 'name': l10n.arabic},
      {'code': 'en', 'countryCode': 'GB', 'name': l10n.english},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final selected = widget.currentLocale == lang['code'];
            return ListTile(
              leading: SizedBox(width: 32, height: 22, child: CountryFlag.fromCountryCode(lang['countryCode'] as String)),
              title: Text(lang['name'] as String,
                  style: TextStyle(color: Colors.white, fontFamily: 'urbanist', fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              trailing: selected ? const Icon(Icons.check, color: Colors.white) : null,
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

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (!_initialOrgCheckDone) {
      return const Scaffold(
        backgroundColor: _bgBot,
        body: Center(child: CircularProgressIndicator(color: _redAccent)),
      );
    }
    if (_isUnderMaintenance) return _buildMaintenanceFullScreen();
    if (_isUpdateRequired) return _buildUpdateFullScreen();
    return _buildHome();
  }

  Widget _buildHome() {
    return Scaffold(
      backgroundColor: _bgBot,
      body: Stack(
        children: [
          // Fond radial + gradient vertical
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_bgTop, _bgMid, _bgBot],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -140, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 520, height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFC8172A).withOpacity(0.55), const Color(0xFFC8172A).withOpacity(0.0)],
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 6),

                    // ════════════════════════════════════════
                    // SLIDER EVENTS (si dispo) puis SWIPER ACTUS
                    // ════════════════════════════════════════
                    if (_showEventsFirst) _buildEventSlider(),
                    if (_showEventsFirst && _hasAnyActu) const SizedBox(height: 12),
                    if (_hasAnyActu) _buildActuSwiper(),

                    const SizedBox(height: 12),
                    _buildWalletCard(context),
                    const SizedBox(height: 12),
                    _buildGridCards(context),
                    const SizedBox(height: 12),
                    _buildBrandBanner(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 22,
            child: CustomBottomNavigation(
              currentIndex: 2,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/events', arguments: {
                      'token': widget.token, 'organizationId': widget.organizationId,
                    });
                    break;
                  case 1:
                    _handleStoreTap(context);
                    break;
                  case 2:
                    break;
                  case 3:
                    if (isLoggedIn) {
                      Navigator.pushNamed(context, '/editProfile', arguments: {
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primary)),
                      const SizedBox(height: 16),
                      Text(l10n.loading, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // HEADER — logo + "Wydad AC" + langue + assistant + déconnexion
  // ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Logo
          SizedBox(
            width: 34, height: 43,
            child: Image.asset(
              'assets/logo1.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 8),
          // Titre
          const Expanded(
            child: Text(
              'Wydad AC',
              style: TextStyle(
                fontFamily: 'urbanist',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.white,
                height: 0.9,
              ),
            ),
          ),
          // Langue
          GestureDetector(
            onTap: () => _showLanguageMenu(context),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Text(widget.currentLocale.toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.04, color: Colors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Assistant
          if (isLoggedIn)
            GestureDetector(
              onTap: () {
                if (_isSupportActivated) {
                  Navigator.pushNamed(context, '/chatbot', arguments: {
                    'token': widget.token, 'organizationId': widget.organizationId,
                  });
                } else {
                  _showSupportUnavailableModal(context);
                }
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _yellow.withOpacity(0.45)),
                  color: _yellow.withOpacity(0.10),
                ),
                child: const Icon(Icons.chat_bubble_outline, color: _yellow, size: 20),
              ),
            ),
          const SizedBox(width: 6),
          // Déconnexion
          if (isLoggedIn)
            GestureDetector(
              onTap: () => _showLogoutConfirmation(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Icon(Icons.power_settings_new, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // SLIDER EVENTS (2 derniers events)
  // ───────────────────────────────────────────────────────────
  Widget _buildEventSlider() {
    return _EventSlider(
      // La key force la reconstruction si la liste change
      key: ValueKey(_homeEvents.map((e) => e['id']).join('-')),
      events: _homeEvents,
      onOpen: _openEvent,
    );
  }

  // ───────────────────────────────────────────────────────────
  // SWIPER ACTUS (boutons "Voir les actualités" + "Visiter la page")
  // ───────────────────────────────────────────────────────────
  Widget _buildActuSwiper() {
    final items = _actuItems;
    return _ActuSwiper(
      key: ValueKey(items.map((e) => '${e['title']}|${e['url']}').join('#')),
      items: items,
      onSeeAll: () => _handleNewsTap(context),
      onVisit: _openUrl,
    );
  }

  /// Ouvre l'URL de l'actu dans une WebView intégrée
  void _openUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _UrlWebViewPage(url: url, title: 'Actus')),
    );
  }

  // ───────────────────────────────────────────────────────────
  // WALLET CARD — fond assets/wydadpay.jpg
  // ───────────────────────────────────────────────────────────
  Widget _buildWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleWalletTap(context),
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0A0203),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _assetBg('assets/wydadpay.jpg', alignment: Alignment.centerLeft),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight, end: Alignment.centerLeft,
                      colors: [
                        const Color(0xFF0A0203).withOpacity(0.94),
                        const Color(0xFF0A0203).withOpacity(0.82),
                        const Color(0xFF0A0203).withOpacity(0.25),
                        const Color(0xFF0A0203).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.36, 0.58, 0.72],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18, top: 12, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('WYDAD PAY',
                          style: TextStyle(
                            fontFamily: 'urbanist', fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.6, color: Colors.white.withOpacity(0.75),
                          )),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _walletLoading
                              ? '—'
                              : _walletBalance.toStringAsFixed(2).replaceAll('.', ','),
                          style: const TextStyle(
                            fontFamily: 'urbanist',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text('MAD',
                            style: TextStyle(
                              fontFamily: 'urbanist', fontSize: 15, fontWeight: FontWeight.w700, color: _yellow,
                            )),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: _yellow, size: 13),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Payer · Transférer · Recharger',
                          style: TextStyle(
                            fontFamily: 'urbanist', fontSize: 9, fontWeight: FontWeight.w300, color: Colors.white.withOpacity(0.85), fontStyle: FontStyle.italic,
                          )),
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
    if (!isLoggedIn) { Navigator.pushNamed(context, '/login'); return; }
    await Navigator.pushNamed(context, '/wallet', arguments: {
      'token': widget.token, 'organizationId': widget.organizationId,
    });
    _loadWalletBalance();
  }

  // ───────────────────────────────────────────────────────────
  // GRILLE : Ticketplace / Store / Fan Zone
  // ───────────────────────────────────────────────────────────
  Widget _buildGridCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTicketplaceCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildStoreCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        _buildFanZoneCard(context),
      ],
    );
  }

  Widget _buildTicketplaceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTicketplaceTap(context),
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _bgMid,
          border: const Border(top: BorderSide(color: _gold, width: 4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _assetBg('assets/ticketplace.jpg'),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [_ink, _ink.withOpacity(0.55), _ink.withOpacity(0.0)],
                      stops: const [0.22, 0.46, 0.72],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_ink.withOpacity(0.55), _ink.withOpacity(0.0)],
                      stops: const [0.0, 0.26],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12, right: 12, top: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold)),
                        const SizedBox(width: 6),
                        const Text('24 OFFRES',
                            style: TextStyle(
                              fontFamily: 'urbanist', fontSize: 11, fontWeight: FontWeight.w800, color: _gold,
                            )),
                      ],
                    ),
                    const Icon(Icons.swap_horiz, color: _gold, size: 20),
                  ],
                ),
              ),
              Positioned(
                left: 12, right: 12, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: _ink.withOpacity(0.7),
                        border: const Border(left: BorderSide(color: _gold, width: 3)),
                      ),
                      child: ClipRect(
                        child: _buildTickerPrices(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ticketplace',
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.white,
                          height: 0.9,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTickerPrices() {
    const items = [
      ['Tribune', '90 MAD'],
      ['Pelouse', '70 MAD'],
      ['VIP', '600 MAD'],
    ];
    return _TickerColumn(items: items);
  }

  // Store → redirige directement vers /boutique
  Widget _buildStoreCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleStoreTap(context),
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF3EEEC),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 0, right: 0, top: 0,
                height: 124,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/store.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: _redAccent),
                    ),
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: Container(width: 6, color: const Color(0xFFD11A2A)),
                    ),
                    Positioned(
                      left: 6, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        color: _redAccent,
                        child: const Text('NOUVEAU 26/27',
                            style: TextStyle(
                              fontFamily: 'urbanist', fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 14, right: 12, top: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Store',
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: _redAccent,
                          height: 1.0,
                        )),
                    SizedBox(height: 2),
                    Text('Maillots officiels Kappa',
                        style: TextStyle(
                          fontFamily: 'urbanist', fontSize: 12, height: 1.25, color: Color(0xFF4A0710),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFanZoneCard(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width - 32;

    return GestureDetector(
      onTap: () => _handleQuizTap(context),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _yellow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 18, top: 0, bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      color: const Color(0xFF4A0710),
                      child: const Text('TICKET VIP À GAGNER',
                          style: TextStyle(
                            fontFamily: 'urbanist', fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _yellow,
                          )),
                    ),
                    const SizedBox(height: 6),
                    const Text('Fan Zone',
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: Color(0xFF4A0710),
                          height: 0.9,
                        )),
                    const SizedBox(height: 4),
                    const Text('QUIZ · VOTE HOMME DU MATCH',
                        style: TextStyle(
                          fontFamily: 'urbanist', fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: Color(0xFF4A0710),
                        )),
                  ],
                ),
              ),
              Positioned(
                right: 0, top: 0, bottom: 0,
                width: cardWidth * 0.46,
                child: ClipPath(
                  clipper: _FanZoneClip(),
                  child: Image.asset(
                    'assets/supporters.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // BANNIÈRE WAC BRAND 170px — image assets/wacbrand.jpg
  // ───────────────────────────────────────────────────────────
  Widget _buildBrandBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const _WacBrandWebViewPage()));
      },
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF050505),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/wacbrand.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF050505)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                      colors: [const Color(0xFF050505), const Color(0xFF050505).withOpacity(0.0)],
                      stops: const [0.42, 0.75],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16, top: 39,
                width: 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('WAC Brand',
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          fontSize: 38,
                          color: Color(0xFFE3202F),
                          height: 0.9,
                        )),
                    SizedBox(height: 6),
                    Text('La collection lifestyle sur wacofficialbrand.com',
                        style: TextStyle(
                          fontFamily: 'urbanist', fontSize: 12, color: Colors.white70,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WIDGETS ANNEXES
// ═══════════════════════════════════════════════════════════

/// Slider des 2 events : PageView auto-défilant (5 s), swipe manuel,
/// indicateurs, boutons "Réserver" et "Acheter" → ouvre directement l'event ciblé.
class _EventSlider extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final void Function(Map<String, dynamic> event) onOpen;

  const _EventSlider({Key? key, required this.events, required this.onOpen}) : super(key: key);

  @override
  State<_EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<_EventSlider> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.events.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.events.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _bgTop,
        boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 40, offset: Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Listener(
              // Pause l'auto-play pendant le toucher, reprend ensuite
              onPointerDown: (_) => _timer?.cancel(),
              onPointerUp: (_) => _startAutoPlay(),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.events.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _EventSlide(
                  event: widget.events[i],
                  onOpen: widget.onOpen,
                ),
              ),
            ),
            // Indicateurs
            if (widget.events.length > 1)
              Positioned(
                right: 16, top: 22,
                child: Row(
                  children: List.generate(widget.events.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 5),
                      width: active ? 22 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: active ? _yellow : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventSlide extends StatelessWidget {
  final Map<String, dynamic> event;
  final void Function(Map<String, dynamic> event) onOpen;

  const _EventSlide({required this.event, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final title = event['name']?.toString() ?? '';
    final imageUrl = event['image']?.toString() ?? '';
    final date = DateTime.tryParse(event['date']?.toString() ?? '');
    final isClosed = event['is_closed'] == true || event['is_closed'] == 1;
    final isPast = date != null && DateTime.now().isAfter(date);
    final saleOpen = !isClosed && !isPast && event['disable_ticket'] != 1;

    String dateLabel = '';
    if (date != null) {
      try {
        dateLabel = '${DateFormat("EEEE d MMMM", 'fr').format(date)} · ${DateFormat("HH:mm").format(date)}';
      } catch (_) {
        dateLabel = date.toString();
      }
    }

    return GestureDetector(
      onTap: () => onOpen(event),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBg(),
            )
          else
            _fallbackBg(),
          // Overlay bas
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_ink.withOpacity(0.10), const Color(0xFF4A0710).withOpacity(0.75), const Color(0xFF4A0710)],
                stops: const [0.20, 0.55, 0.80],
              ),
            ),
          ),
          // Badge VENTE OUVERTE / FERMÉE
          Positioned(
            left: 18, top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: _ink,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: saleOpen ? _yellow : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    saleOpen ? 'VENTE OUVERTE' : 'VENTE FERMÉE',
                    style: const TextStyle(
                      fontFamily: 'urbanist', fontSize: 11, fontWeight: FontWeight.w800,
                      letterSpacing: 1.0, color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenu bas
          Positioned(
            left: 18, right: 18, bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'urbanist', fontSize: 11, fontWeight: FontWeight.w800,
                      letterSpacing: 1.4, color: _yellow,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'urbanist', fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900, fontSize: 28, color: Colors.white, height: 0.95,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.stadiumName,
                  style: TextStyle(fontFamily: 'urbanist', fontSize: 13, color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Réserver
                    GestureDetector(
                      onTap: () => onOpen(event),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Réserver',
                                style: TextStyle(fontFamily: 'urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: _redAccent)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: _redAccent, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Acheter
                    GestureDetector(
                      onTap: () => onOpen(event),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(colors: [Color(0xFFD11A2A), _redAccent]),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.confirmation_num, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(l10n.buy,
                                style: const TextStyle(fontFamily: 'urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
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
    );
  }

  Widget _fallbackBg() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
      ),
    ),
  );
}

/// Swiper des actus : PageView auto-défilant (6 s) + swipe manuel + indicateurs.
/// Chaque slide : image, titre, bouton "Voir les actualités" et,
/// si l'API fournit une URL, bouton "Visiter la page".
class _ActuSwiper extends StatefulWidget {
  final List<Map<String, String>> items;
  final VoidCallback onSeeAll;
  final void Function(String url) onVisit;

  const _ActuSwiper({
    Key? key,
    required this.items,
    required this.onSeeAll,
    required this.onVisit,
  }) : super(key: key);

  @override
  State<_ActuSwiper> createState() => _ActuSwiperState();
}

class _ActuSwiperState extends State<_ActuSwiper> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.items.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.items.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _ink,
        boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 40, offset: Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Listener(
              onPointerDown: (_) => _timer?.cancel(),
              onPointerUp: (_) => _startAutoPlay(),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _slide(widget.items[i]),
              ),
            ),
            // Indicateurs
            if (widget.items.length > 1)
              Positioned(
                right: 16, top: 22,
                child: Row(
                  children: List.generate(widget.items.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 5),
                      width: active ? 22 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: active ? _yellow : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _slide(Map<String, String> item) {
    final title = item['title'] ?? '';
    final image = item['image'] ?? '';
    final url = item['url'] ?? '';
    final hasUrl = url.isNotEmpty;

    return GestureDetector(
      onTap: widget.onSeeAll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNotEmpty)
            Image.network(image, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _bgMid,
                alignment: Alignment.center,
                child: const Icon(Icons.newspaper, color: Colors.white24, size: 80),
              ),
            )
          else
            Container(color: _bgMid),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  _ink.withOpacity(0.55),
                  _ink.withOpacity(0.0),
                  _ink.withOpacity(0.0),
                  const Color(0xFF4A0710).withOpacity(0.75),
                  const Color(0xFF3A050C).withOpacity(0.95),
                ],
                stops: const [0.0, 0.22, 0.38, 0.62, 0.9],
              ),
            ),
          ),
          // Badge ACTUS
          Positioned(
            left: 18, top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: _ink,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.article_outlined, color: _yellow, size: 13),
                  SizedBox(width: 7),
                  Text('ACTUS · PAGE OFFICIELLE',
                      style: TextStyle(
                        fontFamily: 'urbanist', fontSize: 11, fontWeight: FontWeight.w800,
                        letterSpacing: 1.0, color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
          // Contenu bas
          Positioned(
            left: 18, right: 18, bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'urbanist', fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900, fontSize: 26, color: Colors.white, height: 1.0,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Voir les actualités
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onSeeAll,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Flexible(
                                child: Text('Voir les actualités',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'urbanist', fontSize: 13,
                                      fontWeight: FontWeight.w800, color: _redAccent,
                                    )),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, color: _redAccent, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Visiter la page (uniquement si l'API renvoie une URL)
                    if (hasUrl) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onVisit(url),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(colors: [Color(0xFFD11A2A), _redAccent]),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.open_in_new, color: Colors.white, size: 15),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text('Visiter la page',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'urbanist', fontSize: 13,
                                        fontWeight: FontWeight.w800, color: Colors.white,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Colonne défilante de prix (Ticketplace)
class _TickerColumn extends StatefulWidget {
  final List<List<String>> items;
  const _TickerColumn({required this.items});

  @override
  State<_TickerColumn> createState() => _TickerColumnState();
}

class _TickerColumnState extends State<_TickerColumn> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1875), (_) {
      if (mounted) setState(() => _index = (_index + 1) % widget.items.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Row(
          key: ValueKey(_index),
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.items[_index][0],
                  style: const TextStyle(fontFamily: 'urbanist', fontSize: 9, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                widget.items[_index][1],
                style: const TextStyle(
                  fontFamily: 'urbanist',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: _gold,
                  height: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clip polygon pour la Fan Zone : (22% 0, 100% 0, 100% 100%, 0 100%)
class _FanZoneClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.22, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────
// WEBVIEW WAC BRAND (utilisé uniquement par la bannière WAC Brand)
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
      ..setBackgroundColor(_bgBot)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) { if (mounted) setState(() => _isLoading = true); },
          onPageFinished: (_) { if (mounted) setState(() => _isLoading = false); },
        ),
      )
      ..loadRequest(Uri.parse('https://wacofficialbrand.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBot,
      appBar: AppBar(
        backgroundColor: _bgMid,
        foregroundColor: Colors.white,
        title: const Text('WAC Brand',
            style: TextStyle(fontFamily: 'urbanist', fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_redAccent))),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// WEBVIEW GÉNÉRIQUE (bouton "Visiter la page" des actus)
// ─────────────────────────────────────────────────────────────
class _UrlWebViewPage extends StatefulWidget {
  final String url;
  final String title;
  const _UrlWebViewPage({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<_UrlWebViewPage> createState() => _UrlWebViewPageState();
}

class _UrlWebViewPageState extends State<_UrlWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(_bgBot)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) { if (mounted) setState(() => _isLoading = true); },
          onPageFinished: (_) { if (mounted) setState(() => _isLoading = false); },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBot,
      appBar: AppBar(
        backgroundColor: _bgMid,
        foregroundColor: Colors.white,
        title: Text(widget.title,
            style: const TextStyle(fontFamily: 'urbanist', fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_redAccent))),
        ],
      ),
    );
  }
}
