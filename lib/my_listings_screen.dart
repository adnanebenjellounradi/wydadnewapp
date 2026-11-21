import 'package:flutter/material.dart';
import 'ticketplace_service.dart';
import 'publish_resale_screen.dart';

// ═══════════════════════════════════════════════════════════════
// Statuts API (my-listings)
// 0: Disponible | 1: Vendu | 2: Annulé | 3: Réservé | 4: Expiré
// ═══════════════════════════════════════════════════════════════
class ListingStatus {
  static const int available = 0;
  static const int sold = 1;
  static const int cancelled = 2;
  static const int reserved = 3;
  static const int expired = 4;
}

class MyListingsScreen extends StatefulWidget {
  final String token;
  const MyListingsScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // On charge TOUTES les annonces (pas de filtre) pour pouvoir
    // afficher "En vente" (status 0 + 3) et "Vendues" (status 1)
    final l = await TicketplaceService.getMyListings(token: widget.token);

    if (mounted) {
      setState(() {
        _listings = l;
        _loading = false;
      });
    }
  }

  // ─── Annulation (API POST /cancel) ───
  Future<void> _cancel(Map<String, dynamic> listing) async {
    final listingId = listing['id'];
    if (listingId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF23030A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Retirer l\'annonce ?',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: const Text(
          'Vos billets seront restaurés et disponibles pour le match.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Retirer',
              style: TextStyle(
                  color: Color(0xFFFF9C9C), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await TicketplaceService.cancelResale(
      token: widget.token,
      resaleTicketId: listingId is int ? listingId : int.parse('$listingId'),
    );

    if (!mounted) return;

    if (res != null && res['success'] == true) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce annulée, billets restaurés'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Gestion 404 (introuvable) / 422 (déjà vendu ou réservé)
      final msg = res?['message'] ??
          'Impossible d\'annuler l\'annonce (déjà vendue ou réservée).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ─── Modification du prix ───
  // L'API publishResale exige order_child_ids + resale_price.
  // On suppose que PublishResaleScreen gère l'édition quand on lui
  // passe des IDs déjà existants. À adapter si tu as un endpoint PATCH.
  void _editPrice(Map<String, dynamic> listing) {
    // Récupère les IDs de billets depuis la réponse API
    // (l'API my-listings ne les renvoie pas explicitement, mais on peut
    // les reconstituer si ton backend les inclut sous 'order_child_ids'
    // ou 'ticket_ids'. Sinon, on renvoie l'utilisateur vers la page
    // de publication en repartant de zéro.)
    final rawIds = listing['order_child_ids'] ?? listing['ticket_ids'];
    final orderChildIds = rawIds is List
        ? List<int>.from(rawIds.map((e) => e is int ? e : int.parse('$e')))
        : <int>[];

    final originalPrice =
    (listing['original_price'] ?? listing['resale_price'] ?? 0).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublishResaleScreen(
          token: widget.token,
          orderChildIds: orderChildIds,
          originalPrice: originalPrice,
          matchName: listing['event']?['name'] ?? '',
        ),
      ),
    ).then((_) => _load());
  }

  // ─── Total gagné (status 1 = Vendu) ───
  double get _totalEarned {
    double sum = 0;
    for (final l in _listings) {
      final s = (l['status'] is int)
          ? l['status'] as int
          : int.tryParse('${l['status']}') ?? -1;
      if (s == ListingStatus.sold) {
        sum += (l['seller_net_amount'] as num?)?.toDouble() ?? 0;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    // "En vente" = status 0 (Disponible) + 3 (Réservé)
    final available = _listings.where((l) {
      final s = _statusOf(l);
      return s == ListingStatus.available || s == ListingStatus.reserved;
    }).toList();

    // "Vendues" = status 1
    final sold = _listings.where((l) => _statusOf(l) == ListingStatus.sold).toList();

    // Annulées / expirées (optionnel : on peut les afficher en bas)
    final archived = _listings.where((l) {
      final s = _statusOf(l);
      return s == ListingStatus.cancelled || s == ListingStatus.expired;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Stack(
        children: [
          // ─── Fond dégradé + halo rouge ───
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
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

          // ─── Contenu ───
          SafeArea(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.red))
                : RefreshIndicator(
              onRefresh: _load,
              color: Colors.red,
              backgroundColor: const Color(0xFF23030A),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSummary(available.length),

                  // ─── EN VENTE ───
                  if (available.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle('EN VENTE'),
                    const SizedBox(height: 10),
                    ...available.map((l) => _ListingTile(
                      listing: l,
                      onCancel: () => _cancel(l),
                      onEdit: () => _editPrice(l),
                    )),
                  ],

                  // ─── VENDUES ───
                  if (sold.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle('VENDUES'),
                    const SizedBox(height: 10),
                    ...sold.map((l) => _SoldTile(listing: l)),
                  ],

                  // ─── ANNULÉES / EXPIRÉES (optionnel) ───
                  if (archived.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle('ANNULÉES / EXPIRÉES'),
                    const SizedBox(height: 10),
                    ...archived.map((l) => _ArchivedTile(listing: l)),
                  ],

                  // ─── ÉTAT VIDE ───
                  if (_listings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: Colors.white38, size: 56),
                            SizedBox(height: 14),
                            Text(
                              'Aucune annonce pour le moment',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _statusOf(Map<String, dynamic> l) {
    final raw = l['status'];
    if (raw is int) return raw;
    return int.tryParse('$raw') ?? -1;
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0x14FFFFFF),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const Text(
            'Mes annonces',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION RÉSUMÉ
  // ═══════════════════════════════════════════════════════════
  Widget _buildSummary(int availableCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('En vente',
                    style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  '$availableCount annonce${availableCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gagné cette saison',
                    style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  '+${_fmt(_totalEarned)} MAD',
                  style: const TextStyle(
                      color: Color(0xFFF5CD52),
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TITRE DE SECTION
// ═══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0x99FFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TUILE ANNONCE EN VENTE (status 0 ou 3)
// ═══════════════════════════════════════════════════════════════
class _ListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  const _ListingTile({
    required this.listing,
    required this.onCancel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final event = listing['event'] ?? {};
    final ticket = listing['ticket'] ?? {};
    final seats = listing['seats'];
    final count = listing['tickets_count'] ?? 1;
    final price = listing['resale_price'] ?? 0;
    final net = listing['seller_net_amount'] ?? 0;
    final statusLabel = listing['status_label'] ?? 'Disponible';
    final isReserved = (listing['status'] == 3);
    final createdLabel = _relativeDate(listing['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + badge statut
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket['name'] ?? ''} · $count billet${count > 1 ? 's' : ''} · $createdLabel',
                      style: const TextStyle(
                          color: Color(0x99FFFFFF), fontSize: 12),
                    ),
                    if (seats is List && seats.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          (seats.first is Map)
                              ? '${seats.first['porte'] ?? ''} · ${seats.first['secteur'] ?? ''} · ${seats.first['place'] ?? ''}'
                              : '',
                          style: const TextStyle(
                              color: Color(0x80FFFFFF), fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isReserved
                      ? const Color(0xFF5AB8FF).withOpacity(0.14)
                      : const Color(0xFFFFBA5A).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isReserved ? 'Réservé' : statusLabel,
                    style: TextStyle(
                        color: isReserved
                            ? const Color(0xFF8DD0FF)
                            : const Color(0xFFFFC97A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prix + net
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix ${_fmt(price)} MAD · vous recevrez',
                style: const TextStyle(
                    color: Color(0xB8FFFFFF), fontSize: 13),
              ),
              Text(
                '${_fmt(net)} MAD',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Boutons Modifier / Retirer
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isReserved ? null : onEdit,
                  child: Opacity(
                    opacity: isReserved ? 0.4 : 1,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x24FFFFFF)),
                      ),
                      child: const Center(
                        child: Text(
                          'Modifier le prix',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: isReserved ? null : onCancel,
                  child: Opacity(
                    opacity: isReserved ? 0.4 : 1,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x66FF8A8A)),
                      ),
                      child: const Center(
                        child: Text(
                          'Retirer',
                          style: TextStyle(
                              color: Color(0xFFFF9C9C),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
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

// ═══════════════════════════════════════════════════════════════
// TUILE ANNONCE VENDUE (status 1)
// ═══════════════════════════════════════════════════════════════
class _SoldTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _SoldTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    final event = listing['event'] ?? {};
    final ticket = listing['ticket'] ?? {};
    final net = listing['seller_net_amount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5CD52).withOpacity(0.12),
            ),
            child: const Icon(Icons.check,
                color: Color(0xFFF5CD52), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${ticket['name'] ?? ''} · vendu · versé sur le Wallet',
                  style: const TextStyle(
                      color: Color(0x99FFFFFF), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+${_fmt(net)}',
            style: const TextStyle(
                color: Color(0xFFF5CD52),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TUILE ANNONCE ANNULÉE / EXPIRÉE (status 2 ou 4)
// ═══════════════════════════════════════════════════════════════
class _ArchivedTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _ArchivedTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    final event = listing['event'] ?? {};
    final ticket = listing['ticket'] ?? {};
    final label = listing['status_label'] ?? 'Annulée';
    final isExpired = listing['status'] == 4;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x10FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
            child: Icon(
              isExpired ? Icons.timer_off_outlined : Icons.close,
              color: Colors.white38,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'] ?? '',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${ticket['name'] ?? ''} · $label',
                  style: const TextStyle(
                      color: Color(0x66FFFFFF), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
String _fmt(dynamic v) {
  final n = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
  return n.toStringAsFixed(2).replaceAll('.', ',');
}

String _relativeDate(dynamic raw) {
  if (raw == null) return 'date inconnue';
  try {
    final d = DateTime.parse(raw.toString()).toLocal();
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'publiée aujourd\'hui';
    if (diff.inDays == 1) return 'publiée hier';
    if (diff.inDays < 7) return 'publiée il y a ${diff.inDays} jours';
    return 'publiée le ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return 'date inconnue';
  }
}