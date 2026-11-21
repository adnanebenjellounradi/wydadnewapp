import 'package:flutter/material.dart';
import 'ticketplace_service.dart';

class EventListingsScreen extends StatefulWidget {
  final String token;
  final int eventId;
  final String eventName;

  const EventListingsScreen({
    Key? key,
    required this.token,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  State<EventListingsScreen> createState() => _EventListingsScreenState();
}

class _EventListingsScreenState extends State<EventListingsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  int? _selectedTicketId;
  String _sortBy = 'price_asc';

  // Contrôleur pour le slider des zones
  final ScrollController _zoneScrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _load();
    _zoneScrollController.addListener(_updateScrollButtons);
    // Petit délai pour laisser le temps au layout de se construire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _zoneScrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_zoneScrollController.hasClients) return;
    final maxScroll = _zoneScrollController.position.maxScrollExtent;
    final currentScroll = _zoneScrollController.offset;
    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll;
    });
  }

  void _scrollZones(double delta) {
    if (_zoneScrollController.hasClients) {
      _zoneScrollController.animateTo(
        (_zoneScrollController.offset + delta).clamp(
          0.0,
          _zoneScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await TicketplaceService.getEventListings(
      token: widget.token,
      eventId: widget.eventId,
      ticketId: _selectedTicketId,
      sortBy: _sortBy,
    );
    if (mounted) {
      setState(() {
        _data = d;
        _loading = false;
      });
      // Met à jour les boutons du slider après le chargement des zones
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = List<Map<String, dynamic>>.from(_data?['listings'] ?? []);
    final tickets = List<Map<String, dynamic>>.from(_data?['tickets'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
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
          // Contenu
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      // Bouton Retour
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0x14FFFFFF), // 8% blanc
                            border: Border.all(color: const Color(0x24FFFFFF)), // 14% blanc
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Titre et sous-titre
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.eventName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Sam. [DATE] · 20:00 · [STADE]",
                              style: TextStyle(
                                color: Color(0x99FFFFFF), // 60% blanc
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- FILTRES / TRI ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildSortButton(
                        label: 'Prix croissant',
                        icon: Icons.sort,
                        active: _sortBy == 'price_asc',
                        onTap: () {
                          setState(() => _sortBy = 'price_asc');
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSortButton(
                        label: 'Nb de billets',
                        active: _sortBy == 'tickets_count',
                        onTap: () {
                          setState(() => _sortBy = 'tickets_count');
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSortButton(
                        label: 'Budget max',
                        active: _sortBy == 'price_desc',
                        onTap: () {
                          setState(() => _sortBy = 'price_desc');
                          _load();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- SLIDER DES ZONES (Catégories) ---
                if (tickets.isNotEmpty)
                  SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        // Flèche gauche
                        if (_canScrollLeft)
                          GestureDetector(
                            onTap: () => _scrollZones(-150),
                            child: Container(
                              width: 32,
                              height: 36,
                              margin: const EdgeInsets.only(left: 20, right: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0x1AFFFFFF), // 10% blanc
                              ),
                              child: const Icon(Icons.chevron_left, color: Colors.white, size: 18),
                            ),
                          ),
                        // Liste des zones
                        Expanded(
                          child: ListView(
                            controller: _zoneScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(
                              left: _canScrollLeft ? 0 : 20,
                              right: 20,
                            ),
                            children: [
                              _chip('Toutes', _selectedTicketId == null, () {
                                setState(() => _selectedTicketId = null);
                                _load();
                              }),
                              ...tickets.map((t) => _chip(
                                '${t['name']} (${t['available_offers_count']})',
                                _selectedTicketId == t['id'],
                                    () {
                                  setState(() => _selectedTicketId = t['id']);
                                  _load();
                                },
                              )),
                            ],
                          ),
                        ),
                        // Flèche droite
                        if (_canScrollRight)
                          GestureDetector(
                            onTap: () => _scrollZones(150),
                            child: Container(
                              width: 32,
                              height: 36,
                              margin: const EdgeInsets.only(right: 20, left: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0x1AFFFFFF), // 10% blanc
                              ),
                              child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // --- NOMBRE D'ANNONCES ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${listings.length} annonce(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Prix total, hors frais de service",
                        style: TextStyle(
                          color: Color(0x99FFFFFF), // 60% blanc
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- LISTE DES ANNONCES ---
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.red))
                      : listings.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucune annonce',
                      style: TextStyle(color: Color(0xB3FFFFFF)), // 70% blanc
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final l = listings[i];
                      return _ListingCard(
                        listing: l,
                        onBuy: () {
                          Navigator.pushNamed(
                            context,
                            '/ticketplaceBuy',
                            arguments: {
                              'token': widget.token,
                              'listingId': l['id'],
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0x0FFFFFFF), // 6% blanc
          border: Border.all(color: const Color(0x24FFFFFF)), // 14% blanc
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0x2EFFFFFF) : const Color(0x0FFFFFFF), // 18% / 6%
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0x73FFFFFF) : const Color(0x24FFFFFF), // 45% / 14%
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARTE ANNONCE
// ─────────────────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onBuy;
  const _ListingCard({required this.listing, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final total = listing['total_buyer_amount'] ?? listing['resale_price'];
    final seller = listing['seller_name'] ?? 'Vendeur';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF), // 7% blanc
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1FFFFFFF)), // 12% blanc
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing['ticket_name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${listing['tickets_count']} billet(s)',
                      style: const TextStyle(
                        color: Color(0xB8FFFFFF), // 72% blanc
                        fontSize: 12,
                      ),
                    ),
                    const Text(' · ', style: TextStyle(color: Color(0xB8FFFFFF), fontSize: 12)),
                    Text(
                      seller,
                      style: const TextStyle(
                        color: Color(0xB8FFFFFF), // 72% blanc
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Badge vendeur vérifié
                    const Icon(
                      Icons.verified,
                      size: 13,
                      color: Color(0xFFF5CD52),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total MAD',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onBuy,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0x33FFFFFF)), // 20% blanc
                  ),
                  child: const Text(
                    'Acheter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}