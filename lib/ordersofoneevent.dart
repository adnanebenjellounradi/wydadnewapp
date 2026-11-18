import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'transfertHistory.dart';
import 'select_tickets_to_transfer_page.dart'; // E5b
import 'swipetickets.dart'; // ⚠️ adapte le nom réel

class OrdersOfOneEventPage extends StatefulWidget {
  final String token;
  final int eventId;
  final String? currentOrganizationId;

  OrdersOfOneEventPage({
    Key? key,
    required this.token,
    required this.eventId,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  _OrdersOfOneEventPageState createState() => _OrdersOfOneEventPageState();
}

class _OrdersOfOneEventPageState extends State<OrdersOfOneEventPage> {
  List<dynamic> orders = [];
  bool isLoading = false;
  String eventName = '';
  String eventImage = '';
  String eventDate = '';
  bool eventPast = false;
  String? userEmail;

  int _openOrderIndex = -1;

  // ═══════════════════════════════════════════════════════════
  // CACHE DÉTAIL DE COMMANDE (pour avoir order_child)
  // ═══════════════════════════════════════════════════════════
  final Map<int, Map<String, dynamic>> _orderDetailsCache = {};
  final Set<int> _loadingOrderDetails = {};

  final Color primary = const Color(0xFFA8161F);
  final Color gold = const Color(0xFFF5CD52);
  final Color amber = const Color(0xFFFFC97A);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    fetchOrders();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email')?.trim();
    });
  }

  bool isUserReceiver(dynamic order) {
    if (order["order_type"] != "Transfer") return false;
    final receiver = order["receiver"];
    if (receiver == null) return false;
    if (userEmail == null) return false;
    final receiverEmail = receiver["email"]?.toString().trim();
    return receiverEmail != null &&
        receiverEmail.isNotEmpty &&
        receiverEmail == userEmail;
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    final uri = Uri.parse("https://ticketing.ma/api/customer/orders")
        .replace(queryParameters: {
      "event_id": "${widget.eventId}",
      "offset": "0",
      "limit": "10",
      "appversion": "27"
    });

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 426) {
      setState(() => isLoading = false);
      _showUpdateRequiredDialog();
      return;
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        List<dynamic> fetchedOrders = data["data"];
        setState(() {
          orders = fetchedOrders;
          if (orders.isNotEmpty) {
            final event = orders.first["event"];
            eventName = event["name"];
            eventImage = event["image"] ?? '';
            eventDate = DateFormat("dd-MM-yyyy")
                .format(DateTime.parse(event["date"]));
            eventPast =
                DateTime.now().isAfter(DateTime.parse(event["date"]));
          }
        });
      }
    }
    setState(() => isLoading = false);
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH DÉTAIL (contient order_child = la liste des tickets)
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> _fetchOrderDetail(int orderId) async {
    if (_orderDetailsCache.containsKey(orderId)) {
      return _orderDetailsCache[orderId];
    }
    if (_loadingOrderDetails.contains(orderId)) return null;

    setState(() => _loadingOrderDetails.add(orderId));
    try {
      final res = await http.get(
        Uri.parse("https://ticketing.ma/api/customer/orders/$orderId"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true && data["data"] != null) {
          _orderDetailsCache[orderId] = data["data"];
          return data["data"];
        }
      }
    } catch (e) {
      debugPrint("fetchOrderDetail error: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingOrderDetails.remove(orderId));
      } else {
        _loadingOrderDetails.remove(orderId);
      }
    }
    return null;
  }

  double _getOrderTotal(dynamic order) {
    final candidates = [
      order["total"],
      order["amount"],
      order["price"],
      order["total_amount"],
      order["total_price"],
    ];
    for (final c in candidates) {
      if (c == null) continue;
      if (c is num) return c.toDouble();
      final parsed = double.tryParse(c.toString());
      if (parsed != null) return parsed;
    }

    final children = order["order_child"] as List<dynamic>? ?? [];
    if (children.isNotEmpty) {
      double sum = 0;
      for (final child in children) {
        final childPrice =
            child["price"] ?? child["amount"] ?? child["ticket"]?["price"];
        if (childPrice == null) continue;
        if (childPrice is num) {
          sum += childPrice.toDouble();
        } else {
          sum += double.tryParse(childPrice.toString()) ?? 0;
        }
      }
      if (sum > 0) return sum;
    }

    final ticketPrice = order["ticket"]?["price"];
    final qty = order["quantity"];
    if (ticketPrice != null && qty != null) {
      final p = ticketPrice is num
          ? ticketPrice.toDouble()
          : double.tryParse(ticketPrice.toString()) ?? 0;
      final q = qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0;
      return p * q;
    }

    return 0;
  }

  String _buildSeatSubtitle(dynamic order) {
    final ticket = order["ticket"];
    final children = order["order_child"] as List<dynamic>? ?? [];
    final firstChild = children.isNotEmpty ? children.first : null;
    final data = firstChild?["ticket_data"] ?? {};

    final parts = <String>[];
    final cat = ticket?["name"]?.toString();
    if (cat != null && cat.isNotEmpty) parts.add(cat);

    final porte = data["porte"]?.toString();
    if (porte != null && porte.isNotEmpty) parts.add('Porte $porte');

    final place = data["place"]?.toString();
    if (place != null && place.isNotEmpty) parts.add('Place $place');

    return parts.join(' · ');
  }

  void _showUpdateRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: amber.withOpacity(0.14),
                    border: Border.all(color: amber.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.update_rounded, color: amber, size: 34),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.updateRequired,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.updateRequiredMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'urbanist',
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
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.close,
                          style: const TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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

  void logout() async {
    await http.post(
      Uri.parse("https://ticketing.ma/api/customer/logout"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _openTransferSelection() {
    final sourceOrders = orders
        .where((o) => !(o["order_type"] == "Transfer" &&
        isUserReceiver(o) &&
        o["transfer_status"] == 0))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectTicketsToTransferPage(
          token: widget.token,
          eventId: widget.eventId,
          currentOrganizationId: widget.currentOrganizationId,
          eventName: eventName,
          eventDate: eventDate,
          orders: sourceOrders,
          userEmail: userEmail,
        ),
      ),
    ).then((changed) {
      if (changed == true) fetchOrders();
    });
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION VERS SWIPETICKETSPAGE
  // ═══════════════════════════════════════════════════════════
  void _openTicketPage(dynamic order, {dynamic child}) {
    final orderId = order["id"];
    final orderIdAsInt =
    orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;
    if (orderIdAsInt <= 0) return;

    final String? myEmail = userEmail?.trim();
    final orderType = order["order_type"]?.toString();
    final sender = order["sender"];
    final receiver = order["receiver"];

    bool computedIsSender;
    if (orderType != "Transfer" || sender == null) {
      computedIsSender = false;
    } else {
      computedIsSender = sender["email"]?.toString().trim() == myEmail;
    }
    final bool computedIsReceiver =
        receiver != null && receiver["email"]?.toString().trim() == myEmail;

    // Tickets bruts (depuis order_child si présent)
    final children = (order["order_child"] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final List<Map<String, dynamic>> tickets = children.isNotEmpty
        ? children
        : <Map<String, dynamic>>[
      {
        "id": order["ticket"]?["id"],
        "ticket_number": order["ticket_number"] ?? '',
        "status": order["status"] ?? 0,
        "transfer_status": order["transfer_status"],
        "ticket_data": order["ticket_data"],
        "scan_history": order["scan_history"],
      }
    ];

    final List<Map<String, dynamic>> filteredTickets = computedIsSender
        ? tickets.where((t) {
      final s = t["transfer_status"] ?? 20;
      return s != 0;
    }).toList()
        : tickets;

    int initialIndex = 0;
    if (child != null) {
      final childId = child["id"];
      final idx = filteredTickets.indexWhere((t) => t["id"] == childId);
      if (idx >= 0) initialIndex = idx;
    }

    final ticketModel = (order["ticket"] as Map<String, dynamic>?) ??
        <String, dynamic>{
          "name": order["ticket"]?["name"] ?? '',
          "price": order["ticket"]?["price"] ?? 0,
        };

    final Map<String, dynamic> event =
        (order["event"] as Map<String, dynamic>?) ??
            <String, dynamic>{
              "name": eventName,
              "date": order["event"]?["date"] ?? '',
              "address": order["event"]?["address"] ?? '',
              "date_qr_code": order["event"]?["date_qr_code"],
            };

    debugPrint("ORDER: $order");
    debugPrint("TICKETS (${tickets.length}): $tickets");
    debugPrint("isSender=$computedIsSender isReceiver=$computedIsReceiver");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeTicketsPage(
          token: widget.token,
          orderId: orderIdAsInt,
          currentOrganizationId: widget.currentOrganizationId,
          orderData: Map<String, dynamic>.from(order),
          tickets: tickets,
          event: event,
          ticket: ticketModel,
          isQrCode: (order["is_qr_code"] as int?) ?? 1,
          isTransferable: (order["is_transferable"] as int?) ?? 1,
          userEmail: userEmail,
          category: ticketModel["name"]?.toString(),
          isSender: computedIsSender,
          senderEmail: order["sender"]?["email"]?.toString(),
          initialTicketIndex: initialIndex,
          selectedTicketId: child?["id"],
          isReceiver: computedIsReceiver,
        ),
      ),
    ).then((changed) {
      if (changed == true) {
        _orderDetailsCache.remove(orderIdAsInt);
        fetchOrders();
      }
    });
  }

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
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: primary))
              : orders.isEmpty
              ? _buildEmptyState(l10n)
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    _buildHeader(l10n),
                    const SizedBox(height: 16),
                    _buildEventBanner(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildPendingTransfers(l10n),
                      ..._buildReceivedTickets(l10n),
                      _buildOrdersSection(l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/Notfound.gif', width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            l10n.noOrdersFound,
            style: TextStyle(
              fontFamily: 'urbanist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
          Text(
            l10n.myTickets,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'urbanist',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransferHistoryPage(
                    token: widget.token,
                    userEmail: userEmail ?? '',
                    eventId: widget.eventId,
                  ),
                ),
              );
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    l10n.transfersButton,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'urbanist',
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

  Widget _buildEventBanner() {
    final totalTickets = orders.fold<int>(0, (sum, order) {
      final children = order["order_child"] as List<dynamic>? ?? [];
      if (children.isNotEmpty) return sum + children.length;
      return sum + (order["quantity"] as int? ?? 1);
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA8161F), Color(0xFF7A0D17), Color(0xFF4A0710)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName.isNotEmpty ? eventName : l10n.matchPlaceholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'urbanist',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  eventDate.isNotEmpty
                      ? '$eventDate · ${l10n.stadiumName}'
                      : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'urbanist',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalTickets',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'urbanist',
                ),
              ),
              Text(
                totalTickets > 1 ? l10n.ticketPlural : l10n.ticket,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'urbanist',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TRANSFERTS EN ATTENTE
  // ═══════════════════════════════════════════════════════════
  List<Widget> _buildPendingTransfers(AppLocalizations l10n) {
    final pendingOrders = orders
        .where((o) =>
    o["order_type"] == "Transfer" &&
        isUserReceiver(o) &&
        o["transfer_status"] == 0)
        .toList();

    if (pendingOrders.isEmpty) return [];

    return [
      const SizedBox(height: 20),
      Text(
        l10n.pendingTransferLabel('${pendingOrders.length}'),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Color(0xFFFFC97A),
          fontFamily: 'urbanist',
        ),
      ),
      const SizedBox(height: 10),
      ...pendingOrders.map((o) => _buildPendingTransferCard(o, l10n)),
    ];
  }

  Widget _buildPendingTransferCard(dynamic order, AppLocalizations l10n) {
    final senderName = order["sender"]?["name"]?.toString() ??
        order["user"]?["name"]?.toString() ??
        l10n.senderPlaceholder;
    final seatSubtitle = _buildSeatSubtitle(order);
    final orderId = order["id"];
    final orderIdAsInt =
    orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: amber.withOpacity(0.08),
        border: Border.all(color: amber.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: amber.withOpacity(0.16),
                ),
                child:
                Icon(Icons.move_to_inbox_rounded, color: amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.receivedTicketFrom(senderName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'urbanist',
                      ),
                    ),
                    if (seatSubtitle.isNotEmpty)
                      Text(
                        seatSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.72),
                          fontFamily: 'urbanist',
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
                  color: amber.withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.inPendingLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFC97A),
                    fontFamily: 'urbanist',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.transferAcceptInfo,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withOpacity(0.72),
              fontFamily: 'urbanist',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleRefuseTransfer(orderIdAsInt),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Center(
                      child: Text(
                        l10n.refuse,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'urbanist',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleAcceptTransfer(orderIdAsInt),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                      ),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Text(
                        l10n.accept,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'urbanist',
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

  // ═══════════════════════════════════════════════════════════
  // BILLETS REÇUS
  // ═══════════════════════════════════════════════════════════
  List<Widget> _buildReceivedTickets(AppLocalizations l10n) {
    final received = orders
        .where((o) =>
    o["order_type"] == "Transfer" &&
        isUserReceiver(o) &&
        o["transfer_status"] == 1)
        .toList();

    if (received.isEmpty) return [];

    return [
      const SizedBox(height: 20),
      Text(
        '${l10n.receivedTicketsSection.toUpperCase()} · ${received.length}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Colors.white.withOpacity(0.6),
          fontFamily: 'urbanist',
        ),
      ),
      const SizedBox(height: 10),
      ...received.map((o) => _buildReceivedTicketCard(o, l10n)),
    ];
  }

  Widget _buildReceivedTicketCard(dynamic order, AppLocalizations l10n) {
    final senderName = order["sender"]?["name"]?.toString() ??
        order["user"]?["name"]?.toString() ??
        l10n.senderPlaceholder;
    final seatSubtitle = _buildSeatSubtitle(order);
    final ticketName =
        order["ticket"]?["name"]?.toString() ?? l10n.ticketFallback;

    return GestureDetector(
      onTap: () => _openTicketPage(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: gold.withOpacity(0.12),
              ),
              child:
              Icon(Icons.confirmation_number_outlined, color: gold, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.ticket} · $ticketName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'urbanist',
                    ),
                  ),
                  Text(
                    seatSubtitle.isNotEmpty
                        ? '${l10n.receivedFrom} $senderName · $seatSubtitle'
                        : '${l10n.receivedFrom} $senderName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'urbanist',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.validLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF5CD52),
                fontFamily: 'urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptTransfer(int orderId) async {
    try {
      final res = await http.post(
        Uri.parse(
            "https://ticketing.ma/api/customer/orders/$orderId/accept-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          _orderDetailsCache.remove(orderId);
          fetchOrders();
        }
      }
    } catch (e) {
      print('accept transfer error: $e');
    }
  }

  Future<void> _handleRefuseTransfer(int orderId) async {
    try {
      final res = await http.post(
        Uri.parse(
            "https://ticketing.ma/api/customer/orders/$orderId/refuse-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          _orderDetailsCache.remove(orderId);
          fetchOrders();
        }
      }
    } catch (e) {
      print('refuse transfer error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MES COMMANDES (accordéon)
  // ═══════════════════════════════════════════════════════════
  Widget _buildOrdersSection(AppLocalizations l10n) {
    final normalOrders = orders
        .where((o) => !(o["order_type"] == "Transfer" &&
        isUserReceiver(o) &&
        o["transfer_status"] == 0))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myOrdersSection('${normalOrders.length}'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'urbanist',
              ),
            ),
            GestureDetector(
              onTap: _openTransferSelection,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border:
                  Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      l10n.transferTicketsButton,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'urbanist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...normalOrders.asMap().entries.map((entry) {
          return _buildOrderAccordion(
              entry.value, entry.key, normalOrders, l10n);
        }).toList(),
      ],
    );
  }

  Widget _buildOrderAccordion(dynamic order, int index,
      List<dynamic> normalOrders, AppLocalizations l10n) {
    final isOpen = _openOrderIndex == index;
    final orderId = order["id"];
    final orderIdAsInt =
    orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    // ═══ Utilise le détail (cache) si dispo, sinon la version liste ═══
    final detail = _orderDetailsCache[orderIdAsInt];
    final merged = detail != null
        ? <String, dynamic>{...order, ...detail}
        : order;

    final orderChildren =
        (merged["order_child"] as List<dynamic>?) ?? <dynamic>[];

    final isLoadingDetail =
        _loadingOrderDetails.contains(orderIdAsInt) && detail == null;

    final ticketCount = orderChildren.isNotEmpty
        ? orderChildren.length
        : (merged["quantity"] as int? ?? 1);

    final total = _getOrderTotal(merged);
    final totalLabel = '${total.toStringAsFixed(2).replaceAll('.', ',')} MAD';

    final orderType = merged["order_type"]?.toString() ?? '';
    final isTransfer = orderType == "Transfer";
    final transferStatus = merged["transfer_status"] as int?;
    final isReceived = isUserReceiver(merged);

    String badge = l10n.paidLabel;
    Color badgeColor = gold;
    Color badgeBg = gold.withOpacity(0.14);

    if (isTransfer && isReceived) {
      badge = transferStatus == 1 ? l10n.receivedLabel : l10n.inPendingLabel;
      badgeColor = transferStatus == 1 ? gold : amber;
      badgeBg = badgeColor.withOpacity(0.14);
    } else if (isTransfer) {
      badge = l10n.transferredLabel;
      badgeColor = amber;
      badgeBg = badgeColor.withOpacity(0.14);
    }

    final date = merged["created_at"]?.toString() ?? '';
    final dateFormatted = date.length > 16
        ? date.substring(0, 16).replaceAll('T', ' · ')
        : date;
    final paymentMethod =
        merged["payment_method"]?.toString() ?? l10n.walletLabel;
    final ticketName = merged["ticket"]?["name"]?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              final willOpen = !isOpen;
              setState(() {
                _openOrderIndex = willOpen ? index : -1;
              });
              if (willOpen) {
                // ⚠️ Charge le détail pour avoir la vraie liste order_child
                _fetchOrderDetail(orderIdAsInt);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${merged["order_id"] ?? "#$orderIdAsInt"}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'urbanist',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: badgeBg,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                  fontFamily: 'urbanist',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticketName.isNotEmpty
                              ? '$dateFormatted · $ticketName'
                              : dateFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'urbanist',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'urbanist',
                        ),
                      ),
                      Text(
                        '$ticketCount ${ticketCount > 1 ? l10n.ticketPlural : l10n.ticket}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'urbanist',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoadingDetail)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: gold,
                          ),
                        ),
                      ),
                    )
                  else if (orderChildren.isEmpty)
                    _buildTicketRow(
                      order: merged,
                      child: null,
                      orderIdAsInt: orderIdAsInt,
                      index: 0,
                    )
                  else
                    ...orderChildren.asMap().entries.map((entry) => _buildTicketRow(
                      order: merged,
                      child: entry.value,
                      orderIdAsInt: orderIdAsInt,
                      index: entry.key,       // ✅ passe l'index
                    )),
                  const SizedBox(height: 10),
                  Text(
                    l10n.paidOnPayment(dateFormatted, paymentMethod),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'urbanist',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTicketRow({
    required dynamic order,
    required dynamic child,
    required int orderIdAsInt,
    required int index,
  }) {
    final rawTicketNumber = child?["ticket_number"]?.toString() ?? '';
    final ticketNumber = rawTicketNumber.length > 5
        ? '…${rawTicketNumber.substring(rawTicketNumber.length - 5)}'
        : rawTicketNumber;
    final ticketName =
        order["ticket"]?["name"]?.toString() ?? l10n.ticketFallback;
    final isTransfer = order["order_type"] == "Transfer";
    final transferStatus = order["transfer_status"] as int?;
    final isReceived = isUserReceiver(order);

    String stateLabel = l10n.validLabel;
    Color stateColor = gold;
    Color iconBg = gold.withOpacity(0.12);
    Color iconColor = gold;

    if (isTransfer && isReceived) {
      if (transferStatus == 0) {
        stateLabel = l10n.inPendingLabel;
        stateColor = amber;
        iconBg = stateColor.withOpacity(0.12);
        iconColor = stateColor;
      } else if (transferStatus == 1) {
        stateLabel = l10n.validLabel;
      }
    } else if (isTransfer) {
      stateLabel = l10n.transferredLabel;
      stateColor = amber;
      iconBg = stateColor.withOpacity(0.12);
      iconColor = stateColor;
    }

    final label = '${l10n.ticket} ${index + 1} · $ticketName';

    return InkWell(
      onTap: () => _openTicketPage(order, child: child),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: iconBg,
              ),
              child: Icon(Icons.confirmation_number_outlined,
                  color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'urbanist',
                    ),
                  ),
                  if (child?["seat"] != null)
                    Text(
                      child["seat"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'urbanist',
                      ),
                    ),
                ],
              ),
            ),
            Text(
              stateLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: stateColor,
                fontFamily: 'urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}