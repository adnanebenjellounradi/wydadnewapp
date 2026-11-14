import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'transfertHistory.dart';

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
  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
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
                    color: const Color(0xFFFFC97A).withOpacity(0.14),
                    border: Border.all(
                        color: const Color(0xFFFFC97A).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.update_rounded,
                      color: Color(0xFFFFC97A), size: 34),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.updateRequired,
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
                  l10n.updateRequiredMessage,
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
                            fontFamily: 'Inter',
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
                  padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildPendingTransfers(l10n),
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
              fontFamily: 'Inter',
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
            l10n.myOrders,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
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
                      fontFamily: 'Inter',
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
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
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
                    fontFamily: 'Inter',
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
                    fontFamily: 'Inter',
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
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                totalTickets > 1 ? l10n.ticketPlural : l10n.ticket,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          fontFamily: 'Inter',
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
    final ticket = order["ticket"];
    final ticketName = ticket?["name"]?.toString() ?? '';
    final orderId = order["id"];
    final orderIdAsInt =
    orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFFC97A).withOpacity(0.08),
        border: Border.all(color: const Color(0xFFFFC97A).withOpacity(0.35)),
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
                  color: const Color(0xFFFFC97A).withOpacity(0.16),
                ),
                child: const Icon(Icons.move_to_inbox_rounded,
                    color: Color(0xFFFFC97A), size: 20),
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
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (ticketName.isNotEmpty)
                      Text(
                        ticketName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.72),
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
                  color: const Color(0xFFFFC97A).withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.inPendingLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFC97A),
                    fontFamily: 'Inter',
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
              fontFamily: 'Inter',
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
                          fontFamily: 'Inter',
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
                          fontFamily: 'Inter',
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
          fetchOrders();
        }
      }
    } catch (e) {
      print('refuse transfer error: $e');
    }
  }

  Widget _buildOrdersSection(AppLocalizations l10n) {
    final normalOrders = orders
        .where((o) =>
    !(o["order_type"] == "Transfer" &&
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
                fontFamily: 'Inter',
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
    final orderChildren = order["order_child"] as List<dynamic>? ?? [];
    final orderId = order["id"];
    final orderIdAsInt =
    orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0;

    final ticketCount = orderChildren.isNotEmpty
        ? orderChildren.length
        : (order["quantity"] as int? ?? 1);

    final total = _getOrderTotal(order);
    final totalLabel = '${total.toStringAsFixed(2).replaceAll('.', ',')} MAD';

    final orderType = order["order_type"]?.toString() ?? '';
    final isTransfer = orderType == "Transfer";
    final transferStatus = order["transfer_status"] as int?;
    final isReceived = isUserReceiver(order);

    String badge = l10n.paidLabel;
    Color badgeColor = const Color(0xFFF5CD52);
    Color badgeBg = const Color(0xFFF5CD52).withOpacity(0.14);

    if (isTransfer && isReceived) {
      badge = transferStatus == 1 ? l10n.receivedLabel : l10n.inPendingLabel;
      badgeColor = transferStatus == 1
          ? const Color(0xFFF5CD52)
          : const Color(0xFFFFC97A);
      badgeBg = badgeColor.withOpacity(0.14);
    } else if (isTransfer) {
      badge = l10n.transferredLabel;
      badgeColor = const Color(0xFFFFC97A);
      badgeBg = badgeColor.withOpacity(0.14);
    }

    final date = order["created_at"]?.toString() ?? '';
    final dateFormatted = date.length > 16
        ? date.substring(0, 16).replaceAll('T', ' · ')
        : date;
    final paymentMethod =
        order["payment_method"]?.toString() ?? l10n.walletLabel;
    final ticketName = order["ticket"]?["name"]?.toString() ?? '';

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
              setState(() {
                _openOrderIndex = isOpen ? -1 : index;
              });
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
                              '${order["order_id"] ?? "#$orderIdAsInt"}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Inter',
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
                                  fontFamily: 'Inter',
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
                            fontFamily: 'Inter',
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
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '$ticketCount ${ticketCount > 1 ? l10n.ticketPlural : l10n.ticket}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
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
                  if (orderChildren.isEmpty)
                    _buildTicketRow(
                      order: order,
                      child: null,
                      orderIdAsInt: orderIdAsInt,
                    )
                  else
                    ...orderChildren.map((child) => _buildTicketRow(
                      order: order,
                      child: child,
                      orderIdAsInt: orderIdAsInt,
                    )),
                  const SizedBox(height: 10),
                  Text(
                    l10n.paidOnPayment(dateFormatted, paymentMethod),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Inter',
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
  }) {
    final ticketNumber = child?["ticket_number"] ?? '';
    final ticketName =
        order["ticket"]?["name"]?.toString() ?? l10n.ticketFallback;
    final isTransfer = order["order_type"] == "Transfer";
    final transferStatus = order["transfer_status"] as int?;
    final isReceived = isUserReceiver(order);

    String stateLabel = l10n.validLabel;
    Color stateColor = const Color(0xFFF5CD52);
    Color iconBg = const Color(0xFFF5CD52).withOpacity(0.12);
    Color iconColor = const Color(0xFFF5CD52);

    if (isTransfer && isReceived) {
      if (transferStatus == 0) {
        stateLabel = l10n.inPendingLabel;
        stateColor = const Color(0xFFFFC97A);
        iconBg = stateColor.withOpacity(0.12);
        iconColor = stateColor;
      } else if (transferStatus == 1) {
        stateLabel = l10n.validLabel;
      }
    } else if (isTransfer) {
      stateLabel = l10n.transferredLabel;
      stateColor = const Color(0xFFFFC97A);
      iconBg = stateColor.withOpacity(0.12);
      iconColor = stateColor;
    }

    final label = ticketNumber.isNotEmpty
        ? '${l10n.ticketNumberLabel(ticketNumber)} · $ticketName'
        : ticketName;

    return InkWell(
      onTap: () {
        if (orderIdAsInt > 0) {
          Navigator.pushNamed(
            context,
            '/tickets',
            arguments: {
              "token": widget.token,
              "orderId": orderIdAsInt,
              "selectedTicketId": child?["id"],
              "organizationId": widget.currentOrganizationId,
            },
          );
        }
      },
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
                      fontFamily: 'Inter',
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
                        fontFamily: 'Inter',
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
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}