import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'transfertHistory.dart';
import 'swipetickets.dart';
import 'l10n/app_localizations.dart';

class TicketsPage extends StatefulWidget {
  final String token;
  final int orderId;
  final String? currentOrganizationId;

  TicketsPage({
    required this.token,
    required this.orderId,
    this.currentOrganizationId,
  });

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  late Future<Map<String, dynamic>> _orderFuture;
  late Timer _timer;
  Set<int> _selectedTickets = Set<int>();
  String? userEmail;
  bool _userEmailLoaded = false;
  Map<String, dynamic>? orderData;

  final Color primary = const Color(0xFFA8161F);
  final Color gold = const Color(0xFFF5CD52);
  final Color amber = const Color(0xFFFFC97A);

  @override
  void initState() {
    super.initState();
    _orderFuture = fetchOrderDetails().then((data) {
      setState(() {
        orderData = data;
      });
      return data;
    });
    _startTimer();
    _getUserEmail();
  }

  void _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
      _userEmailLoaded = true;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Future<Map<String, dynamic>?> _verifyAndGetCustomerId(String scannedEmail) async {
    final l10n = AppLocalizations.of(context)!;

    if (!scannedEmail.contains("@")) {
      _snack(l10n.invalidEmailFormat, error: true);
      return null;
    }

    final uri = Uri.parse("https://ticketing.ma/api/customer/search")
        .replace(queryParameters: {"email": scannedEmail});

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true && data["data"] != null) {
        final customer = data["data"];
        if (customer["organization_id"].toString() == widget.currentOrganizationId.toString()) {
          return {
            'customerId': customer["id"],
            'email': scannedEmail,
          };
        } else {
          _snack(l10n.userNotInOrganization, error: true);
          return null;
        }
      } else {
        // Invitation
        final shouldInvite = await _showInviteDialog(scannedEmail);
        if (shouldInvite == true) {
          _snack(
            l10n.invitationSentSuccess + " - L'utilisateur doit s'inscrire d'abord",
            warn: true,
          );
        }
        return null;
      }
    } else {
      _snack(l10n.errorCheckingEmail, error: true);
      return null;
    }
  }

  Future<bool?> _showInviteDialog(String scannedEmail) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: _dialogDecoration(),
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
                  child: Icon(Icons.person_add_alt_1, color: amber, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.userNotFound,
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
                  "${l10n.userNotFoundMessage} $scannedEmail,\n${l10n.inviteQuestion}",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: _glassButton(label: l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            await http.post(
                              Uri.parse("https://ticketing.ma/api/customer/send-invitation"),
                              headers: {
                                "Authorization": "Bearer ${widget.token}",
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode({"email": scannedEmail}),
                            );
                            Navigator.pop(context, true);
                            _snack(l10n.invitationSentSuccess);
                          } catch (e) {
                            Navigator.pop(context, false);
                            _snack("${l10n.invitationError}: $e", error: true);
                          }
                        },
                        child: _gradientButton(label: l10n.invite),
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

  Future<void> secureScreen() async {
    try {
      const platform = MethodChannel('secure_channel');
      await platform.invokeMethod('secure');
    } on PlatformException catch (e) {
      debugPrint("Erreur blocage capture : ${e.message}");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchOrderDetails() async {
    final response = await http.get(
      Uri.parse("https://ticketing.ma/api/customer/orders/${widget.orderId}"),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        return data["data"];
      } else {
        throw Exception(data["message"]);
      }
    } else {
      throw Exception("Erreur serveur: ${response.statusCode}");
    }
  }

  String formatDate(String rawDate) {
    try {
      DateTime parsed = DateTime.parse(rawDate);
      String datePart = DateFormat("dd/MM/yyyy").format(parsed);
      String hour = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      return "$datePart • $hour";
    } catch (e) {
      return rawDate;
    }
  }

  String formatTime(String rawDate) {
    try {
      DateTime parsed = DateTime.parse(rawDate);
      return "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  bool isEventPast(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();
      return nowLocal.millisecondsSinceEpoch > eventLocal.millisecondsSinceEpoch;
    } catch (e) {
      return false;
    }
  }

  bool shouldShowQRCode(String eventDate, Map<String, dynamic> event) {
    try {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 1));
      DateTime eventDateTime = DateTime.parse(eventDate).toUtc();

      if (event["date_qr_code"] != null && event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(event["date_qr_code"].toString()).toUtc();
        DateTime oneHourAfterMatch = eventDateTime.add(const Duration(hours: 1));

        bool isAfterOrAtStartTime = now.isAfter(qrCodeDateTime) || now.isAtSameMomentAs(qrCodeDateTime);
        bool isBeforeEndTime = now.isBefore(oneHourAfterMatch);

        return isAfterOrAtStartTime && isBeforeEndTime;
      }

      DateTime sixHoursBefore = eventDateTime.subtract(const Duration(hours: 5));
      return now.isAfter(sixHoursBefore);
    } catch (e) {
      print("Error in shouldShowQRCode: $e");
      return false;
    }
  }

  bool canStillTransfer(String rawDate, Map<String, dynamic> event) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();

      if (event["date_qr_code"] != null && event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(event["date_qr_code"].toString());
        return nowLocal.isBefore(qrCodeDateTime);
      }

      DateTime sixHoursBefore = eventLocal.subtract(const Duration(hours: 5));
      return nowLocal.isBefore(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  bool isTransferAllowed(
      String eventDate,
      int ticketStatus,
      int isTransferable,
      int transferStatus,
      int orderTransferStatus,
      Map<String, dynamic> event,
      ) {
    if (shouldShowQRCode(eventDate, event)) return false;
    if (ticketStatus == 3) return false;
    if (ticketStatus == 1) return false;
    if (transferStatus == 1 || orderTransferStatus == 1) return true;
    if (isTransferable == 0) return false;
    if (transferStatus == 0 || transferStatus == 2) return false;
    return canStillTransfer(eventDate, event);
  }

  bool get isSender {
    if (orderData == null || userEmail == null) return true;
    final orderType = orderData!["order_type"];
    final sender = orderData!["sender"];
    if (orderType == "Transfer" && sender != null) {
      return sender["email"] == userEmail;
    }
    return true;
  }

  bool get isReceiver {
    if (orderData == null || userEmail == null) return false;
    final receiver = orderData!["receiver"];
    if (receiver != null) {
      return receiver["email"] == userEmail;
    }
    return false;
  }

  List<dynamic> get filteredTickets {
    if (orderData == null) return [];
    final orderChild = orderData!["order_child"] as List<dynamic>;
    if (isSender) {
      return orderChild.where((ticket) {
        final transferStatus = ticket["transfer_status"] ?? 20;
        return transferStatus != 0;
      }).toList();
    }
    return orderChild;
  }

  void _toggleTicketSelection(
      int ticketId,
      String eventDate,
      int ticketStatus,
      int isTransferable,
      int transferStatus,
      int orderTransferStatus,
      Map<String, dynamic> event,
      ) {
    if (isTransferAllowed(eventDate, ticketStatus, isTransferable, transferStatus, orderTransferStatus, event)) {
      setState(() {
        if (_selectedTickets.contains(ticketId)) {
          _selectedTickets.remove(ticketId);
        } else {
          _selectedTickets.add(ticketId);
        }
      });
    }
  }

  Future<void> _showBulkTransferModal() async {
    if (_selectedTickets.isEmpty) return;
    final result = await showTransferTicketsModal(_selectedTickets.toList().first);
    if (result != null && result is Map<String, dynamic>) {
      final email = result['email'];
      final customerId = result['customerId'];
      if (email != null && customerId != null) {
        final confirmed = await _showFinalConfirmationModal(email, _selectedTickets.length);
        if (confirmed == true) {
          await _performBulkTransfer(_selectedTickets.toList(), customerId, email);
        }
      }
    }
  }

  Future<bool?> _showFinalConfirmationModal(String email, int ticketCount) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.14),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.swap_horiz, color: gold, size: 34),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.confirmTransfer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.recipient,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Text(
                    email,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: gold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 18, color: gold),
                      const SizedBox(width: 8),
                      Text(
                        "$ticketCount ${l10n.ticketPlural}",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.irreversibleAction,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.confirmTransferQuestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: _glassButton(label: l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: _gradientButton(label: l10n.confirmTransferButton),
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

  Future<String?> _scanQRCode() async {
    final l10n = AppLocalizations.of(context)!;

    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        final cameraController = MobileScannerController();
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.scanQRCode,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        cameraController.dispose();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 300,
                    child: MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            final scannedValue = barcode.rawValue!;
                            cameraController.dispose();
                            Navigator.pop(context, scannedValue);
                            return;
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.positionQRCodeInFrame,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performBulkTransfer(List<int> ticketIds, int customerId, String email) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoader(l10n.transferInProgress);

    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/bulkTransfert"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "recipients": [
            {
              "customer_id": customerId,
              "order_child_ids": ticketIds,
            }
          ]
        }),
      );
      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(
            "🎉 ${ticketIds.length} ${l10n.ticketPlural} ${l10n.transferredSuccessfullyTo} $email",
          );
          setState(() {
            _selectedTickets.clear();
            _orderFuture = fetchOrderDetails().then((data) {
              setState(() {
                orderData = data;
              });
              return data;
            });
          });
        } else {
          _snack("${data["message"] ?? l10n.transferError}", error: true);
        }
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    }
  }

  void _navigateToSingleTicket(
      Map<String, dynamic> ticket,
      Map<String, dynamic> event,
      int isTransferable,
      Map<String, dynamic> orderTicket,
      ) {
    final transferStatus = ticket["transfer_status"] ?? 20;
    String? senderEmail = orderData?["sender"]?["email"];
    String category = orderTicket["name"];
    final isQrCode = orderTicket["is_qr_code"] ?? 0;

    int ticketIndex = filteredTickets.indexOf(ticket);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SwipeTicketsPage(
          token: widget.token,
          orderId: widget.orderId,
          currentOrganizationId: widget.currentOrganizationId,
          orderData: orderData!,
          tickets: filteredTickets,
          event: event,
          category: category,
          ticket: ticket,
          isTransferable: isTransferable,
          isQrCode: isQrCode,
          userEmail: userEmail,
          isSender: isSender,
          senderEmail: senderEmail,
          isReceiver: isReceiver,
          initialTicketIndex: ticketIndex >= 0 ? ticketIndex : 0,
        ),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        setState(() {
          _orderFuture = fetchOrderDetails().then((data) {
            setState(() {
              orderData = data;
            });
            return data;
          });
        });
      }
    });
  }

  Future<void> _acceptTransfer() async {
    final l10n = AppLocalizations.of(context)!;
    _showLoader(l10n.acceptingTransfer);
    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/accept-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"order_id": widget.orderId}),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(l10n.transferAcceptedSuccess);
          setState(() {
            _orderFuture = fetchOrderDetails().then((data) {
              setState(() => orderData = data);
              return data;
            });
          });
          Navigator.pushReplacementNamed(context, '/acceuil', arguments: {
            'token': widget.token,
            'organizationId': widget.currentOrganizationId,
          });
        } else {
          _snack("${l10n.acceptTransferError}: ${data["message"] ?? l10n.unknownError}", error: true);
        }
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    }
  }

  Future<void> _rejectTransfer() async {
    final l10n = AppLocalizations.of(context)!;
    _showLoader(l10n.rejectingTransfer);
    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/reject-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"order_id": widget.orderId}),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(l10n.transferRejectedSuccess, error: true);
          setState(() {
            _orderFuture = fetchOrderDetails().then((data) {
              setState(() => orderData = data);
              return data;
            });
          });
          Navigator.pushReplacementNamed(context, '/acceuil', arguments: {
            'token': widget.token,
            'organizationId': widget.currentOrganizationId,
          });
        } else {
          _snack("${l10n.rejectTransferError}: ${data["message"] ?? l10n.unknownError}", error: true);
        }
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    }
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

  void _snack(String message, {bool error = false, bool warn = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: error ? const Color(0xFFE5484D) : (warn ? amber : primary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLoader(String label) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: _dialogDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: gold),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: FutureBuilder<Map<String, dynamic>>(
            future: _orderFuture,
            builder: (context, snapshot) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(l10n, snapshot),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildBody(snapshot, l10n)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    String title = l10n.myTickets;
    if (snapshot.hasData) {
      title = snapshot.data!["event"]["name"] ?? l10n.myTickets;
    }

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
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 3,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: logout,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.power_settings_new, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<Map<String, dynamic>> snapshot, AppLocalizations l10n) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 64, color: Colors.white.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              l10n.noTicketFound,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final order = snapshot.data!;
    final event = order["event"];
    final ticket = order["ticket"];
    final isTransferable = ticket["is_transferable"] ?? 0;
    final displayTickets = filteredTickets;

    if (displayTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 64, color: Colors.white.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              isSender ? l10n.ticketPendingAcceptance : l10n.noTicketsAvailable,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hasTransferableTickets = displayTickets.any((child) =>
        isTransferAllowed(
          event["date"],
          child["status"],
          isTransferable,
          child["transfer_status"] ?? 20,
          order["transfer_status"] ?? 20,
          event,
        ));

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          children: [
            if (isReceiver && order["transfer_status"] == 0)
              _buildPendingTransferBanner(l10n),
            if (isReceiver) _buildSenderInfoBanner(order, l10n),
            if (!(isReceiver && order["transfer_status"] == 0))
              ...displayTickets.asMap().entries.map((entry) {
                return _buildTicketCard(
                  child: entry.value,
                  event: event,
                  ticket: ticket,
                  index: entry.key,
                  isTransferable: isTransferable,
                  order: order,
                  l10n: l10n,
                );
              }),
          ],
        ),
        if (hasTransferableTickets && (isSender || isReceiver))
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildTransferButton(enabled: _selectedTickets.isNotEmpty, l10n: l10n),
          ),
      ],
    );
  }

  Widget _buildPendingTransferBanner(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Icon(Icons.pending_actions, color: amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.pendingTransferReceived,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _rejectTransfer,
                  child: _glassButton(label: l10n.reject.toUpperCase()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _acceptTransfer,
                  child: _gradientButton(label: l10n.accept.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSenderInfoBanner(Map<String, dynamic> order, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transferInformation,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${l10n.from}: ${order["sender"]["name"]} ${order["sender"]["last_name"]}",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "${l10n.numberOfTickets}: ${order["order_child"].length}",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard({
    required Map<String, dynamic> child,
    required Map<String, dynamic> event,
    required Map<String, dynamic> ticket,
    required int index,
    required int isTransferable,
    required Map<String, dynamic> order,
    required AppLocalizations l10n,
  }) {
    final ticketData = child["ticket_data"];
    final ticketStatus = child["status"];
    final ticketId = child["id"];
    final transferStatus = child["transfer_status"] ?? 20;
    final orderTransferStatus = order["transfer_status"] ?? 20;

    final isTransferableTicket = isTransferAllowed(
      event["date"],
      ticketStatus,
      isTransferable,
      transferStatus,
      orderTransferStatus,
      event,
    );
    final isSelected = _selectedTickets.contains(ticketId);

    return GestureDetector(
      onTap: () {
        if (isTransferableTicket) {
          _toggleTicketSelection(ticketId, event["date"], ticketStatus,
              isTransferable, transferStatus, orderTransferStatus, event);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(isSelected ? 0.10 : 0.06),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.85)
                : Colors.white.withOpacity(0.12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [Color(0xFFA8161F), Color(0xFF6E0B12)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "#${index + 1}  ${ticket?["name"]?.toString() ?? ""}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isTransferableTicket && (isTransferable != 0) && (isSender || isReceiver))
                    GestureDetector(
                      onTap: () => _toggleTicketSelection(
                          ticketId, event["date"], ticketStatus,
                          isTransferable, transferStatus, orderTransferStatus, event),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: primary, size: 14)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (_hasTicketData(ticketData))
                    _buildSeatingInfo(ticketData, l10n),
                  if (_hasTicketData(ticketData)) const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusChip(ticketStatus, l10n),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _navigateToSingleTicket(child, event, isTransferable, ticket),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                l10n.details.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
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
    );
  }

  Widget _buildSeatingInfo(Map<String, dynamic> ticketData, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(l10n.gate, ticketData["porte"]?.toString() ?? "-",
              Icons.door_front_door_rounded),
          _buildInfoItem(l10n.access, ticketData["access"]?.toString() ?? "-",
              Icons.directions_rounded),
          _buildInfoItem(l10n.block, ticketData["secteur"]?.toString() ?? "-",
              Icons.grid_view_rounded),
          _buildInfoItem(l10n.seat, ticketData["place"]?.toString() ?? "-",
              Icons.chair_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(int ticketStatus, AppLocalizations l10n) {
    Map<int, Map<String, dynamic>> statusConfig = {
      0: {"text": l10n.statusNotPrinted.toUpperCase(), "color": gold, "icon": Icons.check_circle_rounded},
      1: {"text": l10n.statusPrinted.toUpperCase(), "color": gold, "icon": Icons.print_rounded},
      2: {"text": l10n.statusTransferred.toUpperCase(), "color": amber, "icon": Icons.send_rounded},
      3: {"text": l10n.statusUsed.toUpperCase(), "color": Colors.white60, "icon": Icons.block_rounded},
    };

    final config = statusConfig[ticketStatus] ??
        {"text": l10n.statusUnknown.toUpperCase(), "color": Colors.white54, "icon": Icons.help_rounded};
    final color = config["color"] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config["icon"] as IconData, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            config["text"],
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton({required bool enabled, required AppLocalizations l10n}) {
    final label = _selectedTickets.isEmpty
        ? l10n.transferTickets.toUpperCase()
        : "${l10n.transfer.toUpperCase()} ${_selectedTickets.length} ${l10n.ticketPlural.toUpperCase()}${_selectedTickets.length > 1 ? 'S' : ''}";

    return GestureDetector(
      onTap: enabled ? _showBulkTransferModal : null,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: enabled
              ? const LinearGradient(
            colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
          )
              : null,
          color: enabled ? null : Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(enabled ? 0.2 : 0.1)),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_and_archive_rounded,
              size: 20,
              color: enabled ? Colors.white : Colors.white30,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.6,
                color: enabled ? Colors.white : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasTicketData(Map<String, dynamic>? ticketData) {
    if (ticketData == null) return false;
    final porte = ticketData["porte"]?.toString().trim() ?? "";
    final access = ticketData["access"]?.toString().trim() ?? "";
    final secteur = ticketData["secteur"]?.toString().trim() ?? "";
    return porte.isNotEmpty || access.isNotEmpty || secteur.isNotEmpty;
  }

  Future<Map<String, dynamic>?> showTransferTicketsModal(int ticketId) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController emailController = TextEditingController();
    String email = "";
    int? customerId;

    final emailEntered = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: _dialogDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "${l10n.transfer} ${_selectedTickets.length} ${l10n.ticketPlural}",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.enterRecipientEmail,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.6), size: 18),
                        hintText: l10n.emailExample,
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (value) {
                        email = value.trim();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final scannedEmail = await _scanQRCode();
                        if (scannedEmail != null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: CircularProgressIndicator(color: gold),
                            ),
                          );
                          final result = await _verifyAndGetCustomerId(scannedEmail);
                          Navigator.pop(context);
                          if (result != null && result['customerId'] != null) {
                            emailController.text = scannedEmail;
                            email = scannedEmail.trim();
                            customerId = result['customerId'];
                            setState(() {});
                            _snack(l10n.emailVerifiedSuccessfully);
                          }
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 16, color: gold),
                            const SizedBox(width: 8),
                            Text(
                              l10n.scanQRCode,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context, false),
                            child: _glassButton(label: l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (email.isEmpty || !email.contains("@")) {
                                _snack(l10n.enterValidEmail, error: true);
                                return;
                              }
                              if (customerId == null) {
                                final result = await _verifyAndGetCustomerId(email);
                                if (result != null && result['customerId'] != null) {
                                  customerId = result['customerId'];
                                } else {
                                  _snack(l10n.userNotFound, error: true);
                                  return;
                                }
                              }
                              Navigator.pop(context, true);
                            },
                            child: _gradientButton(label: l10n.confirm),
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
      },
    );

    if (emailEntered != true) return null;
    if (customerId == null) {
      _snack(l10n.userNotFound, error: true);
      return null;
    }
    return {
      'email': email,
      'customerId': customerId,
    };
  }
}