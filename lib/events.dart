import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'transfertHistory.dart';
import 'l10n/app_localizations.dart';
import 'bottomnavigation.dart';

class EventsPage extends StatefulWidget {
  final String? token;
  final String? currentOrganizationId;

  EventsPage({Key? key, this.token, this.currentOrganizationId})
      : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<dynamic> events = [];
  int offset = 0;
  int limit = 20;
  bool isLoading = false;
  String filter = "all";
  String? userEmail;

  // Onglet actif (billetterie ou ticketplace)
  String currentTab = "billetterie";

  // Pagination pour les événements à venir
  int currentPage = 0;
  final int eventsPerPage = 3;

  final Color primary = const Color(0xFFA8161F);
  final Color gold = const Color(0xFFFEE15A);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userEmail = prefs.getString('userEmail'));
  }

  bool isEventOngoing(String eventDate) {
    try {
      final now = DateTime.now();
      final eventStart = DateTime.parse(eventDate).toLocal();
      final eventEnd = eventStart.add(const Duration(hours: 2));
      return now.isAfter(eventStart) && now.isBefore(eventEnd);
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchEvents({bool resetOffset = true}) async {
    if (resetOffset) {
      offset = 0;
      currentPage = 0;
    }
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            "https://ticketing.ma/api/customer/events?offset=$offset&limit=$limit&organization_id=20"),
        headers: widget.token != null
            ? {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        }
            : {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          List<dynamic> fetchedEvents = data["data"];
          if (filter != "all") {
            final now = DateTime.now();
            fetchedEvents = fetchedEvents.where((event) {
              final date = DateTime.parse(event["date"]);
              return filter == "upcoming"
                  ? date.isAfter(now)
                  : date.isBefore(now);
            }).toList();
          }
          setState(() {
            events = fetchedEvents;
          });
        }
      }
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1C0306),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      size: 28, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.loginRequired,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginToAccess,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.login,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Urbanist',
                      ),
                    ),
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
    if (widget.token == null || widget.token!.isEmpty) {
      _showLoginDialog();
      return;
    }

    setState(() => isLoading = true);
    try {
      final enabled = await _isShopEnabled();
      if (!mounted) return;

      if (enabled) {
        _showStoreChoiceModal(context);
      } else {
        _showShopMaintenanceModal(context);
      }
    } catch (e) {
      if (mounted) _showShopMaintenanceModal(context);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                    fontFamily: 'Urbanist',
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
                    fontFamily: 'Urbanist',
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
                        'organizationId': widget.currentOrganizationId,
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

  Future<bool> _isShopEnabled() async {
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
          final settings = data["data"];
          final enabled = settings["enable_shop"];
          if (enabled is bool) return enabled;
          if (enabled is int) return enabled == 1;
          if (enabled is String) {
            return enabled == "1" || enabled.toLowerCase() == "true";
          }
          return false;
        }
      }
    } catch (e) {
      print("Error checking enable_shop: $e");
    }
    return false;
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
                      fontFamily: 'Urbanist',
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
                      fontFamily: 'Urbanist',
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
            fontFamily: 'Urbanist',
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
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
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
                    fontFamily: 'Urbanist',
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
                    fontFamily: 'Urbanist',
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

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    final featuredEvent = events.isNotEmpty ? events.first : null;
    final otherEvents = events.length > 1 ? events.sublist(1) : <dynamic>[];

    // Pagination
    final totalPages = (otherEvents.length / eventsPerPage).ceil();
    final startIndex = currentPage * eventsPerPage;
    final endIndex = (startIndex + eventsPerPage).clamp(0, otherEvents.length);
    final pageEvents = otherEvents.isEmpty
        ? <dynamic>[]
        : otherEvents.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0103),
      body: Stack(
        children: [
          // Fond dégradé
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
          // Halo rouge
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
            child: Column(
              children: [
                // En-tête avec Titre, Bouton "Mes annonces" et Onglets
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // 1. Header (Titre + Mes annonces)
                      _buildTopHeader(),

                      // 2. Onglets Billetterie / Ticketplace
                      const SizedBox(height: 18),
                      _buildTabs(),

                      // 3. Filtres (seulement si on est sur Billetterie)
                      if (currentTab == "billetterie") ...[
                        const SizedBox(height: 14),
                        _buildFilters(),
                      ],
                    ],
                  ),
                ),
                // Contenu principal
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFEE15A)),
                  )
                      : events.isEmpty
                      ? _noEventsWidget(l10n)
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                    children: [
                      // 1. Événement à la une (Hero)
                      if (featuredEvent != null)
                        _buildFeaturedEvent(
                            featuredEvent as Map<String, dynamic>),
                      const SizedBox(height: 20),
                      // Titre de la liste
                      if (otherEvents.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            l10n.events,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: Colors.white.withOpacity(0.6),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      // 2. Liste des autres événements (paginée)
                      ...pageEvents.map((e) =>
                          _buildEventRow(e as Map<String, dynamic>)),

                      // 3. Pagination
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _paginationButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                enabled: currentPage > 0,
                                onTap: () => setState(() => currentPage--),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.07),
                                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                                ),
                                child: Text(
                                  "${currentPage + 1} / $totalPages",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ),
                              _paginationButton(
                                icon: Icons.arrow_forward_ios_rounded,
                                enabled: currentPage < totalPages - 1,
                                onTap: () => setState(() => currentPage++),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Barre de navigation
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: CustomBottomNavigation(
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    break;
                  case 1:
                    _handleBoutiqueTap(context);
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/acceuil',
                        arguments: {
                          'token': widget.token ?? '',
                          'organizationId': widget.currentOrganizationId,
                        });
                    break;
                  case 3:
                    if (widget.token != null && widget.token!.isNotEmpty) {
                      Navigator.pushNamed(context, '/editProfile', arguments: {
                        'token': widget.token,
                        'toggleTheme': () {},
                        'setLanguage': (String) {},
                        'isDarkMode': false,
                        'currentLocale': 'fr',
                      });
                    } else {
                      _showLoginDialog();
                    }
                    break;
                }
              },
              token: widget.token ?? '',
              organizationId: widget.currentOrganizationId,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER & ONGLETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.eventsTitle, // Ex: "Événements"
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.token == null || widget.token!.isEmpty) {
                _showLoginDialog();
              } else {
                // 🔴 REDIRECTION VERS MES ANNONCES
                Navigator.pushNamed(
                  context,
                  '/mesAnnonces',
                  arguments: {'token': widget.token},
                );
              }
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Mes annonces",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          // Onglet Billetterie
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => currentTab = "billetterie");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: currentTab == "billetterie"
                      ? Colors.white.withOpacity(0.14)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Billetterie",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: currentTab == "billetterie"
                        ? const Color(0xFFFEE15A)
                        : Colors.white.withOpacity(0.72),
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          ),
          // Onglet Ticketplace
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.token == null || widget.token!.isEmpty) {
                  _showLoginDialog();
                } else {
                  // 🔴 REDIRECTION VERS TICKETPLACE
                  Navigator.pushNamed(
                    context,
                    '/ticketplace',
                    arguments: {'token': widget.token},
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: currentTab == "ticketplace"
                      ? Colors.white.withOpacity(0.14)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Ticketplace",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: currentTab == "ticketplace"
                        ? const Color(0xFFFEE15A)
                        : Colors.white.withOpacity(0.72),
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: enabled
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'upcoming', 'label': l10n.upcoming},
      {'id': 'past', 'label': l10n.past},
      {'id': 'all', 'label': l10n.all},
    ];
    return Row(
      children: filters.map((f) {
        final selected = filter == f['id'];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              if (filter != f['id']) {
                setState(() {
                  filter = f['id'] as String;
                  currentPage = 0;
                });
                fetchEvents();
              }
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selected
                    ? Colors.white.withOpacity(0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white.withOpacity(0.14),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                f['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.75),
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _noEventsWidget(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Notfound.gif',
                width: 180,
                height: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.event_busy,
                    color: Colors.white54, size: 80)),
            const SizedBox(height: 16),
            Text(
              l10n.noEventsAvailable,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ÉVÉNEMENT À LA UNE (HERO)
  // ─────────────────────────────────────────────────────────────
  Widget _buildFeaturedEvent(Map<String, dynamic> event) {
    final eventName = event["name"] as String? ?? '';
    final eventDate = DateFormat("EEEE d MMMM", 'fr')
        .format(DateTime.parse(event["date"]));
    final eventTime = DateFormat("HH:mm").format(DateTime.parse(event["date"]));
    final eventImage = event["image"] as String? ?? '';
    final isClosed = event["is_closed"] ?? false;
    final eventPast = DateTime.now().isAfter(DateTime.parse(event["date"]));
    final hasImage = eventImage.isNotEmpty;

    return Container(
      height: 330,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? Image.network(
                eventImage,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                    ),
                  ),
                ),
              )
                  : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x880A0002),
                      Color(0xF50A0002),
                    ],
                    stops: [0.3, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: const Color(0xFF120104).withOpacity(0.78),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFEE15A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isClosed
                          ? l10n.closed.toUpperCase()
                          : l10n.upcoming.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFFFEE15A),
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: () {
                  if (widget.token != null && widget.token!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferHistoryPage(
                          token: widget.token!,
                          userEmail: userEmail ?? '',
                          eventId: event["id"],
                        ),
                      ),
                    );
                  } else {
                    _showLoginDialog();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF120104).withOpacity(0.78),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.swap_horiz,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$eventDate · $eventTime",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: Colors.white,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.stadiumName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.72),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!isClosed && !eventPast && event["disable_ticket"] != 1)
                        _buildHeroButton(
                          label: l10n.buy,
                          icon: Icons.confirmation_num,
                          onTap: () {
                            if (widget.token == null || widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/acheterTicketInEvent',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"],
                                  "organizationId": widget.currentOrganizationId,
                                },
                              );
                            }
                          },
                        ),
                      if (isEventOngoing(event["date"]) &&
                          event["enable_vote_player"] == 1)
                        _buildHeroButton(
                          label: l10n.vote,
                          icon: Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          textColor: Colors.black87,
                          onTap: () {
                            if (widget.token == null || widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/ratePlayers',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"].toString(),
                                  "organizationId": widget.currentOrganizationId,
                                  "eventData": event,
                                },
                              );
                            }
                          },
                        ),
                      _buildHeroButton(
                        label: l10n.myTickets,
                        icon: Icons.confirmation_number_outlined,
                        color: Colors.transparent,
                        textColor: Colors.white,
                        isOutline: true,
                        onTap: () {
                          if (widget.token == null || widget.token!.isEmpty) {
                            _showLoginDialog();
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/ordersOfOneEvent',
                              arguments: {
                                "token": widget.token,
                                "eventId": event["id"],
                                "organizationId": widget.currentOrganizationId,
                                "date_qr_code": event["date_qr_code"] ?? '',
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color textColor = const Color(0xFFA8161F),
    bool isOutline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isOutline ? Colors.transparent : color,
          border: isOutline ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LISTE DES ÉVÉNEMENTS (LIGNES COMPACTES)
  // ─────────────────────────────────────────────────────────────
  Widget _buildEventRow(Map<String, dynamic> event) {
    final eventName = event["name"] as String? ?? '';
    final eventDate = DateFormat("d MMM · HH:mm", 'fr')
        .format(DateTime.parse(event["date"]));
    final eventImage = event["image"] as String? ?? '';
    final isClosed = event["is_closed"] ?? false;
    final eventPast = DateTime.now().isAfter(DateTime.parse(event["date"]));
    final hasImage = eventImage.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 88,
                height: 88,
                child: hasImage
                    ? Image.network(
                  eventImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF2A060C),
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white30),
                  ),
                )
                    : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eventName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (!isClosed && !eventPast && event["disable_ticket"] != 1)
                        _buildRowButton(
                          label: l10n.buy,
                          icon: Icons.confirmation_num,
                          onTap: () {
                            if (widget.token == null || widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/acheterTicketInEvent',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"],
                                  "organizationId": widget.currentOrganizationId,
                                },
                              );
                            }
                          },
                        ),
                      if (isEventOngoing(event["date"]) &&
                          event["enable_vote_player"] == 1)
                        _buildRowButton(
                          label: l10n.vote,
                          icon: Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          textColor: Colors.black87,
                          onTap: () {
                            if (widget.token == null || widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/ratePlayers',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"].toString(),
                                  "organizationId": widget.currentOrganizationId,
                                  "eventData": event,
                                },
                              );
                            }
                          },
                        ),
                      _buildRowButton(
                        label: l10n.myTickets,
                        icon: Icons.confirmation_number_outlined,
                        isOutline: true,
                        onTap: () {
                          if (widget.token == null || widget.token!.isEmpty) {
                            _showLoginDialog();
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/ordersOfOneEvent',
                              arguments: {
                                "token": widget.token,
                                "eventId": event["id"],
                                "organizationId": widget.currentOrganizationId,
                                "date_qr_code": event["date_qr_code"] ?? '',
                              },
                            );
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          if (widget.token != null && widget.token!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransferHistoryPage(
                                  token: widget.token!,
                                  userEmail: userEmail ?? '',
                                  eventId: event["id"],
                                ),
                              ),
                            );
                          } else {
                            _showLoginDialog();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.swap_horiz, color: Colors.white, size: 20),
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
    );
  }

  Widget _buildRowButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color textColor = Colors.white,
    bool isOutline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isOutline ? Colors.transparent : (color ?? const Color(0xFFB0141F)),
          border: Border.all(
            color: isOutline ? Colors.white.withOpacity(0.28) : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
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
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
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
                      fontFamily: 'Urbanist',
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