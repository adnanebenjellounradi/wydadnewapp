import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class MesCommandesPage extends StatefulWidget {
  final String token;

  MesCommandesPage({Key? key, required this.token}) : super(key: key);

  @override
  _MesCommandesPageState createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalOrders = 0;
  int limit = 5;
  int offset = 0;
  bool isLoadingPage = false;

  final Color primary = const Color(0xFFA8161F);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (mounted) fetchOrders();
    });
  }

  Future<void> fetchOrders({int page = 1}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      isLoadingPage = true;
      currentPage = page;
      offset = (page - 1) * limit;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://ticketing.ma/api/customer/store/orders?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final allFetchedOrders =
        List<Map<String, dynamic>>.from(data['data'] ?? []);
        final fetchedOrders = allFetchedOrders
            .where((order) => order['payment_status'] == 1)
            .toList();
        setState(() {
          orders = fetchedOrders;
          totalOrders = fetchedOrders.length;
          if (fetchedOrders.length < limit) {
            totalPages = currentPage;
          } else {
            totalPages = currentPage + 1;
          }
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.errorLoadingOrders,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;
        isLoadingPage = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async {
    final l10n = AppLocalizations.of(context)!;
    final response = await http.get(
      Uri.parse('https://ticketing.ma/api/customer/store/orders/$orderId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    throw Exception(l10n.failedToLoadOrderDetails);
  }

  Future<void> deleteOrder(int orderId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final response = await http.delete(
        Uri.parse('https://ticketing.ma/api/customer/store/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          orders.removeWhere((order) => order['id'] == orderId);
          totalOrders = orders.length;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.orderDeletedSuccess,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(l10n.failedToDeleteOrder);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.errorDeletingOrder),
        backgroundColor: Colors.red,
      ));
    }
  }

  String getStatusText(int status, AppLocalizations l10n) {
    switch (status) {
      case 0: return l10n.statusNotProcessed;
      case 1: return l10n.statusProcessing;
      case 2: return l10n.statusProcessed;
      case 3: return l10n.statusDelivered;
      case 4: return l10n.statusCancelled;
      default: return l10n.statusUnknown;
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0: return const Color(0xFFFFC97A);
      case 1: return const Color(0xFF64B5F6);
      case 2: return const Color(0xFFBA68C8);
      case 3: return const Color(0xFF66BB6A);
      default: return Colors.white54;
    }
  }

  void _showOrderDetailsModal(int orderId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final orderDetails = await fetchOrderDetails(orderId);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return OrderDetailsModal(
            orderDetails: orderDetails,
            token: widget.token,
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.errorLoadingOrderDetails,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final inProgress =
    orders.where((o) => o['status'] != null && (o['status'] as int) < 3).toList();
    final delivered =
    orders.where((o) => o['status'] == 3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
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
        child: Stack(
          children: [
            // Glow radial
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(),
                  ),

                  // Contenu
                  Expanded(
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                        : orders.isEmpty
                        ? _buildEmptyState(l10n)
                        : RefreshIndicator(
                      color: primary,
                      onRefresh: () => fetchOrders(page: currentPage),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                            20, 20, 20, 40),
                        children: [
                          if (inProgress.isNotEmpty) ...[
                            _sectionLabel('EN COURS'),
                            const SizedBox(height: 10),
                            ...inProgress.map((o) =>
                                _buildOrderCard(o, isInProgress: true)),
                          ],
                          if (delivered.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            _sectionLabel('PRÉCÉDENTES'),
                            const SizedBox(height: 10),
                            ...delivered.map((o) =>
                                _buildOrderCard(o, isInProgress: false)),
                          ],
                          if (totalPages > 1) ...[
                            const SizedBox(height: 20),
                            _buildPagination(),
                          ],
                        ],
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

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
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
          const Text(
            'Mes commandes',
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
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Colors.white.withOpacity(0.6),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/Notfound.gif',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag_outlined,
                color: Colors.white30, size: 80),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOrdersFound,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ordersWillAppearHere,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/boutique'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.goToStore,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARTE COMMANDE
  // ═══════════════════════════════════════════════════════════
  Widget _buildOrderCard(Map<String, dynamic> order,
      {required bool isInProgress}) {
    final orderId = order['id'];
    final orderIdStr = order['order_id'] ?? '';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final status = (order['status'] as int?) ?? 0;
    final createdAt = order['created_at'] ?? '';
    final quantity = order['quantity'] ?? 0;
    final orderItems = order['order_items'] ?? [];

    if (isInProgress) {
      // Carte "EN COURS" détaillée avec progression
      return GestureDetector(
        onTap: () => _showOrderDetailsModal(orderId),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header : Commande + badge statut
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande $orderIdStr',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$quantity articles · ${total.toStringAsFixed(0)} MAD · passée le ${createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: getStatusColor(status).withOpacity(0.16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      getStatusText(status, AppLocalizations.of(context)!)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: getStatusColor(status),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barre de progression 4 étapes
              _buildProgressBar(status),
              const SizedBox(height: 16),

              // Aperçu produits + info livraison
              Row(
                children: [
                  _buildProductThumbs(orderItems),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Livraison prévue',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Transporteur : WAC Express',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => _showOrderDetailsModal(orderId),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.08),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voir les détails',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Carte "PRÉCÉDENTES" compacte
    return GestureDetector(
      onTap: () => _showOrderDetailsModal(orderId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF5CD52).withOpacity(0.12),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFFF5CD52), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande $orderIdStr',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$quantity article${quantity > 1 ? 's' : ''} · livrée',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${total.toStringAsFixed(0)} MAD',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int status) {
    final steps = ['Confirmée', 'Préparée', 'Expédiée', 'Livrée'];
    return Row(
      children: List.generate(4, (i) {
        final isDone = i <= status;
        final isCurrent = i == status;
        final color = isCurrent
            ? const Color(0xFFFFC97A)
            : isDone
            ? const Color(0xFFF5CD52)
            : Colors.white.withOpacity(0.16);
        final textColor = isCurrent
            ? const Color(0xFFFFC97A)
            : isDone
            ? Colors.white
            : Colors.white.withOpacity(0.6);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductThumbs(List<dynamic> orderItems) {
    final images = orderItems
        .where((i) => i['product']?['image'] != null)
        .map((i) => i['product']['image'])
        .toList();

    if (images.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.06),
        ),
        child: const Icon(Icons.shopping_bag,
            color: Colors.white54, size: 22),
      );
    }

    return SizedBox(
      width: 108,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  images[0],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.shopping_bag,
                      color: Colors.black26,
                      size: 22),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 32,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    images[1],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag,
                        color: Colors.black26,
                        size: 22),
                  ),
                ),
              ),
            ),
          if (images.length > 2)
            Positioned(
              left: 64,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFA8161F),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+${images.length - 2}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Précédent
        GestureDetector(
          onTap: currentPage > 1 && !isLoadingPage
              ? () => fetchOrders(page: currentPage - 1)
              : null,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(
              Icons.chevron_left,
              color: currentPage > 1
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Page X / Y
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Text(
            '$currentPage / $totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Suivant
        GestureDetector(
          onTap: currentPage < totalPages && !isLoadingPage
              ? () => fetchOrders(page: currentPage + 1)
              : null,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(
              Icons.chevron_right,
              color: currentPage < totalPages
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MODAL DÉTAILS — design dark glass
// ═══════════════════════════════════════════════════════════
class OrderDetailsModal extends StatelessWidget {
  final Map<String, dynamic> orderDetails;
  final String token;
  final VoidCallback? onPay;

  const OrderDetailsModal({
    Key? key,
    required this.orderDetails,
    required this.token,
    this.onPay,
  }) : super(key: key);

  Color _statusColor(int status) {
    switch (status) {
      case 0: return const Color(0xFFFFC97A);
      case 1: return const Color(0xFF64B5F6);
      case 2: return const Color(0xFFBA68C8);
      case 3: return const Color(0xFF66BB6A);
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = orderDetails;
    final orderId = order['order_id'] ?? '';
    final subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0.0;
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final quantity = order['quantity'] ?? 0;
    final deliveryPrice =
        (order['delivery_price'] as num?)?.toDouble() ?? 0.0;
    final status = (order['status'] as int?) ?? 0;
    final paymentStatus = (order['payment_status'] as int?) ?? 0;
    final customerName = order['customer_name'] ?? '';
    final customerPhone = order['customer_phone'] ?? '';
    final customerAddress = order['customer_address'] ?? '';
    final createdAt = order['created_at'] ?? '';
    final orderItems =
    List<Map<String, dynamic>>.from(order['order_items'] ?? []);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF170205),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.08),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  'Commande $orderId',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut
                  Row(
                    children: [
                      _statusBadge(
                          'Statut', _statusText(status, l10n),
                          _statusColor(status)),
                      const SizedBox(width: 8),
                      _statusBadge(
                          'Paiement',
                          _paymentText(paymentStatus, l10n),
                          paymentStatus == 1
                              ? const Color(0xFF66BB6A)
                              : const Color(0xFFFF8A8A)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Informations de livraison'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.05),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.person, customerName),
                        const SizedBox(height: 8),
                        _infoRow(Icons.phone, customerPhone),
                        const SizedBox(height: 8),
                        _infoRow(Icons.location_on, customerAddress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('${l10n.orderedItems} ($quantity)'),
                  const SizedBox(height: 10),
                  ...orderItems.map((item) {
                    final product = item['product'];
                    final size = item['size'];
                    final qty = item['quantity'];
                    final itemSubtotal =
                        (item['subtotal'] as num?)?.toDouble() ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: product != null &&
                                  product['image'] != null
                                  ? Image.network(
                                product['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag,
                                    color: Colors.black26),
                              )
                                  : const Icon(Icons.shopping_bag,
                                  color: Colors.black26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product != null
                                      ? product['name'] ?? ''
                                      : l10n.unknownProduct,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (size != null)
                                  Text(
                                    '${l10n.size}: ${size['name']} · ${l10n.quantity}: $qty',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${itemSubtotal.toStringAsFixed(0)} MAD',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.05),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(l10n.subtotal,
                            '${subtotal.toStringAsFixed(0)} MAD'),
                        const SizedBox(height: 8),
                        _summaryRow(l10n.deliveryFee,
                            '${deliveryPrice.toStringAsFixed(0)} MAD'),
                        const SizedBox(height: 10),
                        Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 10),
                        _summaryRow(
                            l10n.total, '${total.toStringAsFixed(0)} MAD',
                            bold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bouton payer
          if (paymentStatus == 0)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF170205),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final orderData = {
                      'token': token,
                      'organizationId': null,
                      'order': {
                        'order_id': order['id'],
                        'order_number': orderId,
                      },
                      'eventId': null,
                      'products': orderItems.map((item) {
                        final product = item['product'];
                        return {
                          'id': product['id'],
                          'name': product['name'],
                          'price': product['price'],
                          'quantity': item['quantity'],
                          'size': item['size']['name'],
                        };
                      }).toList(),
                    };

                    Navigator.pushNamed(context, '/cmiPaymentBoutique',
                        arguments: {
                          'amount': total,
                          'orderData': orderData,
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFA8161F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.payNow,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: color.withOpacity(0.8),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFA8161F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? Colors.white : Colors.white.withOpacity(0.72),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: bold ? 17 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _statusText(int status, AppLocalizations l10n) {
    switch (status) {
      case 0: return l10n.statusNotProcessed;
      case 1: return l10n.statusProcessing;
      case 2: return l10n.statusProcessed;
      case 3: return l10n.statusDelivered;
      case 4: return l10n.statusCancelled;
      default: return l10n.statusUnknown;
    }
  }

  String _paymentText(int status, AppLocalizations l10n) {
    switch (status) {
      case 0: return l10n.statusNotPaid;
      case 1: return l10n.statusPaid;
      default: return l10n.statusUnknown;
    }
  }
}