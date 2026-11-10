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
  int currentPage = 0;
  final int cardsPerPage = 2;
  String? userEmail;

  final Color primary = const Color(0xFFA8161F);

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
    if (resetOffset) offset = 0;
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
            currentPage = 0;
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      size: 28, color: Color(0xFFA8161F)),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.loginRequired,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginToAccess,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                    fontFamily: 'Inter',
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
                            fontFamily: 'Inter',
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
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
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

  // ═══════════════════════════════════════════════════════════
  // MODAL CHOIX BOUTIQUE (comme acceuil.dart)
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
                        'organizationId': widget.currentOrganizationId,
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

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final totalPages = (events.length / cardsPerPage).ceil();
    final startIndex = currentPage * cardsPerPage;
    final endIndex = (startIndex + cardsPerPage).clamp(0, events.length);
    final pageEvents = events.isEmpty
        ? <dynamic>[]
        : events.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Stack(
        children: [
          // Fond
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
            child: Column(
              children: [
                // Header + filtres
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildFilters(),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFA8161F)),
                  )
                      : pageEvents.isEmpty
                      ? _noEventsWidget(l10n)
                      : ListView(
                    padding:
                    const EdgeInsets.fromLTRB(20, 14, 20, 120),
                    children: [
                      ...pageEvents.map((e) =>
                          _buildEventCard(e as Map<String, dynamic>)),
                      if (events.length > cardsPerPage)
                        _buildPagination(totalPages),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: CustomBottomNavigation(
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                  // Déjà sur Événements
                    break;
                  case 1:
                  // Boutique → modal Kappa / WAC Brand
                    if (widget.token == null || widget.token!.isEmpty) {
                      _showLoginDialog();
                    } else {
                      _showStoreChoiceModal(context);
                    }
                    break;
                  case 2:
                  // Accueil
                    Navigator.pushReplacementNamed(context, '/acceuil',
                        arguments: {
                          'token': widget.token ?? '',
                          'organizationId': widget.currentOrganizationId,
                        });
                    break;
                  case 3:
                  // Profil
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Événements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'upcoming', 'label': 'À venir'},
      {'id': 'past', 'label': 'Passés'},
      {'id': 'all', 'label': 'Tous'},
    ];
    return Row(
      children: filters.map((f) {
        final selected = filter == f['id'];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              if (filter != f['id']) {
                setState(() => filter = f['id'] as String);
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
                  fontFamily: 'Inter',
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
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final l10n = AppLocalizations.of(context)!;
    final eventName = event["name"] as String? ?? '';
    final eventDate =
    DateFormat("dd-MM-yyyy").format(DateTime.parse(event["date"]));
    final eventPast = DateTime.now().isAfter(DateTime.parse(event["date"]));
    final eventImage = event["image"] as String? ?? '';
    final isClosed = event["is_closed"] ?? false;
    final hasImage = eventImage.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + overlay + titre + date
              SizedBox(
                height: 176,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: const Color(0xFF23030A)),
                    if (hasImage)
                      Image.network(
                        eventImage,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.28),
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
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                          ),
                        ),
                      ),
                    // Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF120104).withOpacity(0),
                            const Color(0xFF120104).withOpacity(0.75),
                            const Color(0xFF120104).withOpacity(0.97),
                          ],
                          stops: const [0.45, 0.72, 1.0],
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFF120104).withOpacity(0.7),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.18)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isClosed
                              ? l10n.closed
                              : (eventPast
                              ? '${l10n.closedOn} $eventDate'
                              : '${l10n.startsOn} $eventDate'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isClosed
                                ? const Color(0xFFFEE15A)
                                : Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    // Titre
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complexe Mohammed V',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.78),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    // Acheter / Vote / (désactivé)
                    if (!isClosed &&
                        !eventPast &&
                        event["disable_ticket"] != 1)
                      Expanded(
                        child: _buildCTAButton(
                          label: l10n.buy,
                          icon: Icons.confirmation_num,
                          onTap: () {
                            if (widget.token == null ||
                                widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/acheterTicketInEvent',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"],
                                  "organizationId":
                                  widget.currentOrganizationId,
                                },
                              );
                            }
                          },
                        ),
                      ),
                    if (isEventOngoing(event["date"]) &&
                        event["enable_vote_player"] == 1)
                      Expanded(
                        child: _buildCTAButton(
                          label: l10n.vote,
                          icon: Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          textColor: Colors.black87,
                          onTap: () {
                            if (widget.token == null ||
                                widget.token!.isEmpty) {
                              _showLoginDialog();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/ratePlayers',
                                arguments: {
                                  "token": widget.token,
                                  "eventId": event["id"].toString(),
                                  "organizationId":
                                  widget.currentOrganizationId,
                                  "eventData": event,
                                },
                              );
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Mes billets
                    Expanded(
                      child: _buildOutlineButton(
                        label: l10n.myTickets,
                        icon: Icons.confirmation_number_outlined,
                        onTap: () {
                          if (widget.token == null ||
                              widget.token!.isEmpty) {
                            _showLoginDialog();
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/ordersOfOneEvent',
                              arguments: {
                                "token": widget.token,
                                "eventId": event["id"],
                                "organizationId":
                                widget.currentOrganizationId,
                                "date_qr_code": event["date_qr_code"] ?? '',
                              },
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Transfert
                    GestureDetector(
                      onTap: () {
                        if (widget.token != null &&
                            widget.token!.isNotEmpty) {
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
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(Icons.swap_horiz,
                            color: Colors.white, size: 22),
                      ),
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

  Widget _buildCTAButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFFB0141F),
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: color == const Color(0xFFB0141F)
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB0141F), Color(0xFF860D16)],
          )
              : null,
          color: color == const Color(0xFFB0141F) ? null : color,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                fontFamily: 'Inter',
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