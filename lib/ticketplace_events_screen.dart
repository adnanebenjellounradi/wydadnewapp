import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ticketplace_service.dart';
import 'bottomnavigation.dart';
import 'l10n/app_localizations.dart';

class TicketplaceEventsScreen extends StatefulWidget {
  final String token;
  final String? currentOrganizationId;

  const TicketplaceEventsScreen({
    Key? key,
    required this.token,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  State<TicketplaceEventsScreen> createState() => _TicketplaceEventsScreenState();
}

class _TicketplaceEventsScreenState extends State<TicketplaceEventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await TicketplaceService.getEvents(token: widget.token);
    if (mounted) {
      setState(() {
        _events = list;
        _loading = false;
      });
    }
  }

  // Retour à l'onglet Billetterie (EventsPage)
  void _goToBilletterie() {
    Navigator.pushReplacementNamed(
      context,
      '/events',
      arguments: {
        'token': widget.token,
        'organizationId': widget.currentOrganizationId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0103),
      body: Stack(
        children: [
          // 1. Fond dégradé
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
          // 2. Halo rouge
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
          // 3. Contenu
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // --- HEADER IDENTIQUE À EventsPage ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top header (Titre + Mes annonces)
                      _buildTopHeader(),

                      // 2. Onglets Billetterie / Ticketplace
                      const SizedBox(height: 18),
                      _buildTabs(),

                      // 3. Intro Ticketplace (remplace les filtres de EventsPage)
                      const SizedBox(height: 18),
                      const Text(
                        "REVENTE OFFICIELLE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: Color(0xB8FFFFFF),
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Vous avez raté la vente,\npas le match.",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.2,
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Badges de confiance
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0x0FFFFFFF),
                          border: Border.all(color: const Color(0x1FFFFFFF)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTrustBadge("Billets contrôlés"),
                            _buildTrustBadge("Transfert sécurisé"),
                            _buildTrustBadge("Prix plafonnés"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // --- LISTE DES MATCHS ---
                Expanded(
                  child: _loading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFEE15A)))
                      : _events.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucune offre disponible',
                      style: TextStyle(color: Color(0xB3FFFFFF)),
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Offres disponibles",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xDBFFFFFF),
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                      ..._events.map((e) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 12),
                        child: _EventCard(
                          event: e,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ticketplaceListings',
                              arguments: {
                                'token': widget.token,
                                'eventId': e['id'],
                                'eventName': e['name'] ?? '',
                              },
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Barre de navigation en bas
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: CustomBottomNavigation(
              currentIndex: 0, // Events
              onTap: (index) {
                switch (index) {
                  case 0:
                    _goToBilletterie();
                    break;
                  case 1:
                  // Boutique → géré par EventsPage habituellement
                    Navigator.pushReplacementNamed(context, '/home',
                        arguments: {
                          'token': widget.token,
                          'organizationId': widget.currentOrganizationId,
                        });
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/acceuil',
                        arguments: {
                          'token': widget.token,
                          'organizationId': widget.currentOrganizationId,
                        });
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/editProfile',
                        arguments: {
                          'token': widget.token,
                          'organizationId': widget.currentOrganizationId,
                        });
                    break;
                }
              },
              token: widget.token,
              organizationId: widget.currentOrganizationId,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP HEADER (identique à EventsPage)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.eventsTitle, // "Événements"
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/mesAnnonces',
                arguments: {'token': widget.token},
              );
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

  // ═══════════════════════════════════════════════════════════
  // ONGLETS (identique à EventsPage, mais Ticketplace sélectionné)
  // ═══════════════════════════════════════════════════════════
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
          // Onglet Billetterie (non sélectionné → tap = retour EventsPage)
          Expanded(
            child: GestureDetector(
              onTap: _goToBilletterie,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Billetterie",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.72),
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ),
          ),
          // Onglet Ticketplace (sélectionné)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: Colors.white.withOpacity(0.14),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Ticketplace",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFEE15A),
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 13, color: Color(0xFFF5CD52)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xE0FFFFFF),
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARTE MATCH (inchangée)
// ─────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final count = event['active_resale_count'] ?? 0;
    final minPrice = event['min_resale_price'];

    String dateStr = '';
    try {
      final dt = DateTime.parse(event['date']);
      dateStr =
          DateFormat("EEE d MMM · HH:mm", 'fr').format(dt).toUpperCase();
    } catch (_) {
      dateStr = event['date'] ?? '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Date + Badge offres)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xB8FFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontFamily: 'Urbanist',
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: count > 0
                        ? const LinearGradient(
                        colors: [Color(0xFFD11A2A), Color(0xFFA8161F)])
                        : null,
                    color: count == 0 ? const Color(0x1FFFFFFF) : null,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '$count offres',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Équipes
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1FFFFFFF),
                  ),
                  child: const Icon(Icons.sports_soccer,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event['address'] ?? '',
                        style: const TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 12,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Footer (Prix + Bouton)
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xB8FFFFFF),
                        fontFamily: 'Urbanist',
                      ),
                      children: [
                        const TextSpan(text: 'À partir de '),
                        TextSpan(
                          text: '${minPrice ?? "55"} MAD',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Voir les offres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Urbanist',
                      ),
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