import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SwipeTicketsPage extends StatefulWidget {
  final String token;
  final int orderId;
  final String? currentOrganizationId;
  final Map<String, dynamic> orderData;
  final List<dynamic> tickets;
  final Map<String, dynamic> event;
  final Map<String, dynamic> ticket;
  final int isTransferable;
  final int isQrCode;
  final String? userEmail;
  final bool isSender;
  final String? category;
  final String? senderEmail;
  final int initialTicketIndex;
  final bool isReceiver;

  const SwipeTicketsPage({
    Key? key,
    required this.token,
    required this.orderId,
    this.currentOrganizationId,
    required this.orderData,
    required this.tickets,
    required this.event,
    required this.ticket,
    required this.isQrCode,
    required this.isTransferable,
    this.userEmail,
    this.category,
    required this.isSender,
    this.senderEmail,
    this.initialTicketIndex = 0,
    required this.isReceiver,
  }) : super(key: key);

  @override
  _SwipeTicketsPageState createState() => _SwipeTicketsPageState();
}

class _SwipeTicketsPageState extends State<SwipeTicketsPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late Timer _timer;
  late AnimationController _controller;
  int _currentIndex = 0;
  Set<int> _selectedTickets = Set<int>();
  bool _showTransferButton = false;
  List<dynamic> _filteredTickets = [];
  Future<String?>? _cachedDeviceIdFuture;
  String? _cachedDeviceId;
  Map<String, dynamic>? _cachedScanHistory;
  int? _cachedTicketIndex;
  Widget? _cachedWarningWidget;
  Widget? _cachedQRCodeWidget;
  int? _cachedQRCodeTicketIndex;
  Map<String, dynamic>? _cachedQRCodeScanHistory;
  String? _cachedQRCodeTicketNumber;

  final Color primary = const Color(0xFFA8161F);
  final Color gold = const Color(0xFFF5CD52);
  final Color amber = const Color(0xFFFFC97A);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _filteredTickets = _filterTickets(widget.tickets);

    int validIndex = widget.initialTicketIndex;
    if (validIndex >= _filteredTickets.length) {
      validIndex = 0;
    }
    _currentIndex = validIndex;
    _pageController = PageController(initialPage: validIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _filteredTickets.isNotEmpty) {
        _pageController.jumpToPage(validIndex);
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  List<dynamic> _filterTickets(List<dynamic> tickets) {
    if (widget.isSender) {
      return tickets.where((ticket) {
        final transferStatus = ticket["transfer_status"] ?? 20;
        return transferStatus != 0;
      }).toList();
    }
    return tickets;
  }

  bool isTransferAllowed(
      String eventDate,
      int ticketStatus,
      int isTransferable,
      int transferStatus,
      int orderTransferStatus,
      ) {
    if (shouldShowQRCode(eventDate)) return false;
    if (ticketStatus == 3) return false;
    if (ticketStatus == 1) return false;
    if (transferStatus == 1 || orderTransferStatus == 1) return true;
    if (isTransferable == 0) return false;
    if (transferStatus == 0 || transferStatus == 2) return false;
    return canStillTransfer(eventDate);
  }

  bool canStillTransfer(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();

      if (widget.event["date_qr_code"] != null && widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(widget.event["date_qr_code"].toString());
        return nowLocal.isBefore(qrCodeDateTime);
      }

      DateTime sixHoursBefore = eventLocal.subtract(const Duration(hours: 5));
      return nowLocal.isBefore(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  void _toggleTicketSelection(int ticketId, String eventDate, int ticketStatus, int isTransferable, int transferStatus, int orderTransferStatus) {
    if (isTransferAllowed(eventDate, ticketStatus, isTransferable, transferStatus, orderTransferStatus) && canStillTransfer(eventDate)) {
      setState(() {
        if (_selectedTickets.contains(ticketId)) {
          _selectedTickets.remove(ticketId);
        } else {
          _selectedTickets.add(ticketId);
        }
        // ✅ Correction : isNotEmpty au lieu de isSelected
        _showTransferButton = _selectedTickets.isNotEmpty;
      });
    }
  }
  Future<String?> _scanQRCodeForEmail() async {
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
      builder: (context) => Dialog(
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
      ),
    );
  }

  Future<void> _showBulkTransferModal() async {
    if (_selectedTickets.isEmpty) return;
    final result = await showTransferTicketsModal();
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
          _snack("🎉 ${ticketIds.length} ${l10n.ticketPlural} ${l10n.transferredSuccessfullyTo} $email");
          Navigator.pop(context, true);
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

  Future<Map<String, dynamic>?> showTransferTicketsModal() async {
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
                        final scannedEmail = await _scanQRCodeForEmail();
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

  void _navigateBackToTickets() {
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
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

    if (_cachedTicketIndex != _currentIndex) {
      _cachedWarningWidget = null;
      _cachedScanHistory = null;
      _cachedTicketIndex = null;
      _cachedDeviceIdFuture = null;
    }
    if (_cachedQRCodeTicketIndex != _currentIndex) {
      _cachedQRCodeWidget = null;
      _cachedQRCodeTicketIndex = null;
      _cachedQRCodeTicketNumber = null;
      _cachedQRCodeScanHistory = null;
      _cachedDeviceIdFuture = null;
    }

    if (_filteredTickets.isEmpty) {
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeader(l10n, '${l10n.myTickets}', showLogout: false),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 64, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          widget.isSender
                              ? l10n.ticketPendingAcceptance
                              : l10n.noTicketsAvailable,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
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

    final List<bool> transferableTickets = _filteredTickets.map((ticket) {
      return isTransferAllowed(
        widget.event["date"],
        ticket["status"],
        widget.isTransferable,
        ticket["transfer_status"] ?? 20,
        widget.orderData["transfer_status"] ?? 20,
      ) && canStillTransfer(widget.event["date"]);
    }).toList();

    final hasTransferableTickets = transferableTickets.contains(true);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(
                  l10n,
                  '${l10n.ticket} ${_currentIndex + 1}/${_filteredTickets.length}',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _filteredTickets.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[index];
                        final isCurrentTicketTransferable = transferableTickets[index];
                        final isSelected = _selectedTickets.contains(ticket["id"]);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          child: Column(
                            children: [
                              if (isCurrentTicketTransferable)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _toggleTicketSelection(
                                          ticket["id"],
                                          widget.event["date"],
                                          ticket["status"],
                                          widget.isTransferable,
                                          ticket["transfer_status"] ?? 20,
                                          widget.orderData["transfer_status"] ?? 20,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected ? primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: primary),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isSelected ? Icons.check : Icons.add,
                                                color: isSelected ? Colors.white : primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isSelected ? l10n.selected : l10n.selectForTransfer,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: isSelected ? Colors.white : primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildTicketContent(ticket, index),
                            ],
                          ),
                        );
                      },
                    ),

                    if (_filteredTickets.length > 1) ...[
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (_currentIndex > 0) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.14)),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: _currentIndex > 0 ? gold : Colors.white24,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (_currentIndex < _filteredTickets.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.14)),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _currentIndex < _filteredTickets.length - 1 ? gold : Colors.white24,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (hasTransferableTickets && _showTransferButton)
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: _showBulkTransferModal,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_and_archive_rounded,
                                    size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTickets.isEmpty
                                      ? l10n.transferTickets.toUpperCase()
                                      : "${l10n.transfer.toUpperCase()} ${_selectedTickets.length} ${l10n.ticketPlural.toUpperCase()}${_selectedTickets.length > 1 ? 'S' : ''}",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildHeader(AppLocalizations l10n, String title, {bool showLogout = true}) {
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
          if (showLogout)
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
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildTicketContent(Map<String, dynamic> ticket, int index) {
    final l10n = AppLocalizations.of(context)!;

    final ticketData = ticket["ticket_data"];
    final ticketNumber = ticket["ticket_number"];
    final ticketStatus = ticket["status"];
    final event = widget.event;
    final isTransferable = widget.isTransferable;
    final transferStatus = ticket["transfer_status"] ?? 20;

    String statusText = "";
    Color statusColor = Colors.white54;

    switch (ticketStatus) {
      case 0:
        statusText = l10n.statusNotPrinted;
        statusColor = gold;
        break;
      case 1:
        statusText = l10n.statusPrinted;
        statusColor = primary;
        break;
      case 2:
        statusText = l10n.statusTransferred;
        statusColor = gold;
        break;
      case 3:
        statusText = l10n.statusUsed;
        statusColor = const Color(0xFFE5484D);
        break;
      default:
        statusText = l10n.statusUnknown;
    }

    Widget mainContent;
    if (isEventEnded(event["date"])) {
      mainContent = _buildInfoMessage(Icons.event_busy, l10n.eventEnded);
    } else if (isTransferable == 0) {
      mainContent = _buildInfoMessage(Icons.block, l10n.qrCodeNotAuthorized);
    } else if (ticketStatus == 2) {
      mainContent = _buildInfoMessage(Icons.confirmation_number, l10n.ticketAlreadyTransferred);
    } else if (ticketStatus == 1) {
      mainContent = _buildInfoMessage(Icons.confirmation_number, l10n.usePhysicalTicket);
    } else if (!shouldShowQRCode(event["date"])) {
      mainContent = _buildInfoMessage(
        Icons.schedule,
        widget.isQrCode == 0 ? l10n.usePhysicalTicket : l10n.qrCodeWillAppearBeforeMatch,
      );
    } else if (widget.isQrCode == 0) {
      mainContent = _buildInfoMessage(Icons.qr_code, l10n.qrCodeNotAvailableForCategory);
    } else {
      mainContent = _buildQRCodeContent(ticketNumber, ticketStatus, event["date"]);
    }

    return Column(
      children: [
        if (!widget.isSender && transferStatus == 0)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: amber.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.receivedTransferPending,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: amber,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (isTransferable == 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: amber.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: amber, size: 14),
                const SizedBox(width: 8),
                Text(
                  l10n.ticketNotTransferable,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: amber,
                  ),
                ),
              ],
            ),
          ),

        if (shouldShowCountdown(event["date"]) && isTransferable != 0 && !isEventStarted(event["date"]))
          _buildCountdown(event["date"], ticketStatus),

        if (ticketStatus != 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${l10n.ticketStatus}: ",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        Text(
          event["name"],
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(event["date"]),
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: gold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          event["address"],
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        mainContent,

        const SizedBox(height: 24),

        if (_hasTicketData(ticketData))
          _buildSeatingInfo(ticketData),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: amber.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.individualTicketInfo,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!widget.isSender && transferStatus == 0) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _acceptTransfer(ticket["id"]),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3CA55C), Color(0xFF1E7A38)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    l10n.acceptTransfer,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _rejectTransfer(ticket["id"]),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, size: 18, color: Color(0xFFE5484D)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.rejectTransfer,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoMessage(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: gold),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<String?> _getDeviceIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceIdPrefrences');
  }

  Widget _buildQRCodeContent(String ticketNumber, int ticketStatus, String eventDate) {
    final l10n = AppLocalizations.of(context)!;
    final ticket = widget.tickets[_currentIndex];
    final scanHistory = ticket["scan_history"];
    final hasBeenScanned = scanHistory != null && scanHistory["device_id"] != null;
    final scanStatus = scanHistory != null ? scanHistory["status"] : null;

    if (_cachedQRCodeWidget != null &&
        _cachedQRCodeTicketIndex == _currentIndex &&
        _cachedQRCodeTicketNumber == ticketNumber &&
        _cachedQRCodeScanHistory == scanHistory) {
      return _cachedQRCodeWidget!;
    }

    Widget result;
    if (hasBeenScanned) {
      if (_cachedDeviceIdFuture == null) {
        _cachedDeviceIdFuture = _getDeviceIdFromPrefs();
      }
      result = FutureBuilder<String?>(
        future: _cachedDeviceIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: gold));
          }
          if (snapshot.hasData && snapshot.data != null) {
            final currentDeviceId = snapshot.data!;
            final scannedDeviceId = scanHistory["device_id"].toString();
            final isSameDevice = currentDeviceId == scannedDeviceId;

            if (isSameDevice) {
              Color borderColor = primary;
              String? scanMessage;

              if (scanStatus != null) {
                if (scanStatus == 0) {
                  borderColor = Colors.blue;
                  scanMessage = l10n.scannedAtBarrier;
                } else if (scanStatus == 1) {
                  borderColor = amber;
                  scanMessage = l10n.scannedAtDoor;
                }
              }
              return _buildNormalQRCode(
                ticketNumber,
                ticketStatus,
                eventDate,
                showUsedBanner: false,
                borderColor: borderColor,
                scanMessage: scanMessage,
              );
            } else {
              return _buildScannedFromOtherDeviceMessage(scanHistory);
            }
          }
          return _buildNormalQRCode(ticketNumber, ticketStatus, eventDate, showUsedBanner: true);
        },
      );
    } else {
      result = _buildNormalQRCode(ticketNumber, ticketStatus, eventDate, showUsedBanner: true);
    }

    _cachedQRCodeWidget = result;
    _cachedQRCodeTicketIndex = _currentIndex;
    _cachedQRCodeTicketNumber = ticketNumber;
    _cachedQRCodeScanHistory = scanHistory;

    return result;
  }

  Widget _buildNormalQRCode(
      String ticketNumber,
      int ticketStatus,
      String eventDate, {
        bool showUsedBanner = true,
        Color borderColor = const Color(0xFFA8161F),
        String? scanMessage,
      }) {
    final l10n = AppLocalizations.of(context)!;

    return CustomPaint(
      painter: _FourNDottedBorderPainter(
        animation: _controller,
        radius: 20,
        color: borderColor,
        strokeWidth: 12,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${l10n.category}: ",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFFA8161F),
                    ),
                  ),
                  TextSpan(
                    text: widget.category ?? "",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFFA8161F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            QrImageView(
              data: ticketNumber,
              size: 220,
              backgroundColor: Colors.white,
            ),
            if (scanMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    scanMessage,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: borderColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedFromOtherDeviceMessage(Map<String, dynamic> scanHistory) {
    final l10n = AppLocalizations.of(context)!;
    final scanDate = scanHistory["enter_at"] != null
        ? _formatDateTime(scanHistory["enter_at"])
        : l10n.unknownDate;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5484D).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5484D).withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFE5484D)),
          const SizedBox(height: 16),
          Text(
            l10n.ticketAlreadyScanned,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scannedFromOtherDevice,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today, l10n.scanDate, scanDate),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.devices, l10n.scanDevice, l10n.otherDevice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: gold),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      final l10n = AppLocalizations.of(context)!;

      if (difference.inDays > 0) {
        return "${difference.inDays} ${l10n.day}${difference.inDays > 1 ? 's' : ''}";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} ${l10n.hour}${difference.inHours > 1 ? 's' : ''}";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} ${l10n.minute}${difference.inMinutes > 1 ? 's' : ''}";
      } else {
        return l10n.justNow;
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildCountdown(String eventDate, int ticketStatus) {
    final l10n = AppLocalizations.of(context)!;
    String timeRemaining = getTimeRemaining(eventDate);
    if (timeRemaining != l10n.eventOngoing && ticketStatus != 2 && ticketStatus != 3) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              (!isEventPast(eventDate) || !isEventStarted(eventDate)) ? "" : l10n.eventStartsIn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Color(0xFFE5484D), size: 18),
                const SizedBox(width: 6),
                Text(
                  timeRemaining,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFFE5484D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSeatingInfo(Map<String, dynamic> ticketData) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(l10n.gate, ticketData["porte"]?.toString() ?? "-", Icons.door_front_door_rounded),
          _buildInfoItem(l10n.access, ticketData["access"]?.toString() ?? "-", Icons.directions_rounded),
          _buildInfoItem(l10n.block, ticketData["secteur"]?.toString() ?? "-", Icons.grid_view_rounded),
          _buildInfoItem(l10n.seat, ticketData["place"]?.toString() ?? "-", Icons.chair_rounded),
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

  String _formatDate(String rawDate) {
    final l10n = AppLocalizations.of(context)!;
    try {
      DateTime parsed = DateTime.parse(rawDate);
      String datePart = DateFormat("dd-MM-yyyy").format(parsed);
      String hour = parsed.minute == 0
          ? "${parsed.hour}h"
          : "${parsed.hour}h${parsed.minute.toString().padLeft(2, '0')}";
      return "$datePart ${l10n.at} $hour";
    } catch (e) {
      return rawDate;
    }
  }

  bool shouldShowQRCode(String eventDate) {
    try {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 1));
      DateTime eventDateTime = DateTime.parse(eventDate).toUtc();

      if (widget.event["date_qr_code"] != null && widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(widget.event["date_qr_code"].toString()).toUtc();
        DateTime oneHourAfterMatch = eventDateTime.add(const Duration(hours: 1));
        bool isAfterOrAtStartTime = now.isAfter(qrCodeDateTime) || now.isAtSameMomentAs(qrCodeDateTime);
        bool isBeforeEndTime = now.isBefore(oneHourAfterMatch);
        return isAfterOrAtStartTime && isBeforeEndTime;
      } else {
        DateTime sixHoursBefore = eventDateTime.subtract(const Duration(hours: 5));
        return now.isAfter(sixHoursBefore);
      }
    } catch (e) {
      print("Error in shouldShowQRCode: $e");
      return false;
    }
  }

  bool shouldShowCountdown(String eventDate) {
    try {
      if (widget.event["date_qr_code"] != null && widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(widget.event["date_qr_code"].toString());
        DateTime now = DateTime.now();
        DateTime nowLocal = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);

        DateTime eventDateTime = DateTime.parse(eventDate);
        DateTime oneHourAfterMatch = eventDateTime.add(const Duration(hours: 1));

        return nowLocal.isAfter(qrCodeDateTime) && nowLocal.isBefore(oneHourAfterMatch);
      }

      DateTime eventDateTime = DateTime.parse(eventDate);
      DateTime now = DateTime.now();
      DateTime nowLocal = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
      DateTime fiveHoursBefore = eventDateTime.subtract(const Duration(hours: 5));
      DateTime endOfEventDay = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day + 1);
      return nowLocal.isAfter(fiveHoursBefore) && nowLocal.isBefore(endOfEventDay);
    } catch (e) {
      print("Error in shouldShowCountdown: $e");
      return false;
    }
  }

  String getTimeRemaining(String eventDate) {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (widget.event["date_qr_code"] != null && widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime = DateTime.parse(widget.event["date_qr_code"].toString());
        DateTime eventDateTime = DateTime.parse(eventDate);
        DateTime oneHourAfterMatch = eventDateTime.add(const Duration(hours: 1));
        DateTime now = DateTime.now();

        if (now.millisecondsSinceEpoch < qrCodeDateTime.millisecondsSinceEpoch) {
          Duration remaining = qrCodeDateTime.difference(now);
          return _formatDuration(remaining);
        } else if (now.millisecondsSinceEpoch < eventDateTime.millisecondsSinceEpoch) {
          Duration remaining = eventDateTime.difference(now);
          return _formatDuration(remaining);
        } else if (now.millisecondsSinceEpoch < oneHourAfterMatch.millisecondsSinceEpoch) {
          Duration remaining = oneHourAfterMatch.difference(now);
          int minutes = remaining.inMinutes.remainder(60);
          int seconds = remaining.inSeconds.remainder(60);
          if (remaining.inMinutes > 0) {
            return "${remaining.inMinutes}${l10n.min} ${seconds}${l10n.sec}";
          } else {
            return "${seconds}${l10n.sec}";
          }
        } else {
          return l10n.eventOngoing;
        }
      }

      String localDateString = eventDate.replaceAll('Z', '');
      DateTime eventDateTime = DateTime.parse(localDateString);
      DateTime now = DateTime.now();

      if (now.millisecondsSinceEpoch < eventDateTime.millisecondsSinceEpoch) {
        Duration remaining = eventDateTime.difference(now);
        return _formatDuration(remaining);
      } else {
        DateTime oneHourAfterStart = eventDateTime.add(const Duration(hours: 1));
        if (now.millisecondsSinceEpoch < oneHourAfterStart.millisecondsSinceEpoch) {
          Duration remaining = oneHourAfterStart.difference(now);
          int minutes = remaining.inMinutes.remainder(60);
          int seconds = remaining.inSeconds.remainder(60);
          if (remaining.inMinutes > 0) {
            return "${remaining.inMinutes}${l10n.min} ${seconds}${l10n.sec}";
          } else {
            return "${seconds}${l10n.sec}";
          }
        } else {
          return l10n.eventOngoing;
        }
      }
    } catch (e) {
      print("Error in getTimeRemaining: $e");
      return l10n.invalidDate;
    }
  }

  String _formatDuration(Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return "${days}${l10n.days} ${hours}${l10n.hours} ${minutes}${l10n.min}";
    } else if (hours > 0) {
      return "${hours}${l10n.hours} ${minutes}${l10n.min} ${seconds}${l10n.sec}";
    } else if (minutes > 0) {
      return "${minutes}${l10n.min} ${seconds}${l10n.sec}";
    } else {
      return "${seconds}${l10n.sec}";
    }
  }

  void logout() async {
    try {
      await http.post(
        Uri.parse("https://ticketing.ma/api/customer/logout"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  bool isEventPast(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime oneHourAfterEventEnd = eventLocal.add(const Duration(hours: 1));
      DateTime nowLocal = DateTime.now();
      return nowLocal.isAfter(oneHourAfterEventEnd);
    } catch (e) {
      return false;
    }
  }

  bool isEventStarted(String rawDate) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();
      return nowLocal.millisecondsSinceEpoch > eventLocal.millisecondsSinceEpoch;
    } catch (e) {
      return false;
    }
  }

  bool isEventEnded(String eventDate) {
    try {
      DateTime eventDateTime = DateTime.parse(eventDate);
      DateTime now = DateTime.now();
      DateTime twoHoursAfterStart = eventDateTime.add(const Duration(hours: 1));
      return now.isAfter(twoHoursAfterStart);
    } catch (e) {
      return false;
    }
  }

  bool _hasTicketData(Map<String, dynamic>? ticketData) {
    if (ticketData == null) return false;
    final porte = ticketData["porte"]?.toString().trim() ?? "";
    final access = ticketData["access"]?.toString().trim() ?? "";
    final secteur = ticketData["secteur"]?.toString().trim() ?? "";
    return porte.isNotEmpty || access.isNotEmpty || secteur.isNotEmpty;
  }

  Future<bool?> _showFinalConfirmationModal(String email, int ticketCount) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => Dialog(
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
                    fontSize: 15,
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
      ),
    );
  }

  Future<void> _acceptTransfer(int ticketId) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoader(l10n.transferInProgress);
    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/accept-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"order_id": widget.orderId}),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(l10n.transferAcceptedSuccess);
          Navigator.pop(context, true);
        } else {
          _snack("${data["message"] ?? l10n.acceptTransferError}", error: true);
        }
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    }
  }

  Future<void> _rejectTransfer(int ticketId) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoader(l10n.transferInProgress);
    try {
      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/reject-transfer"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"order_id": widget.orderId}),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(l10n.transferRejected, warn: true);
          Navigator.pop(context, true);
        } else {
          _snack("${data["message"] ?? l10n.rejectTransferError}", error: true);
        }
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// PAINTERS (inchangés)
// ═══════════════════════════════════════════════════════════

class _FourNDottedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;
  final Color color;
  final double strokeWidth;

  _FourNDottedBorderPainter({
    required this.animation,
    required this.radius,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final metric = path.computeMetrics().first;
    final totalLength = metric.length;
    final offset = (animation.value * totalLength * 0.5) % totalLength;
    final segmentLength = totalLength / 4;
    final dashLength = segmentLength * 0.7;
    final dashPath = Path();

    for (int i = 0; i < 4; i++) {
      double startPosition = (i * segmentLength + offset) % totalLength;
      final extract = metric.extractPath(startPosition, startPosition + dashLength);
      dashPath.addPath(extract, Offset.zero);
    }

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.4),
          color.withOpacity(0.9),
          color.withOpacity(0.4),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(dashPath, paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(dashPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

late AnimationController controller;

class _ThreeNDottedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;
  final Color color;
  final double strokeWidth;

  _ThreeNDottedBorderPainter({
    required this.animation,
    required this.radius,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final metric = path.computeMetrics().first;
    final totalLength = metric.length;

    final double t = (math.sin(animation.value * 2 * math.pi) * 0.3) + 0.5;
    final offset = (animation.value * totalLength * 0.15 + t * 20) % totalLength;
    final segmentLength = totalLength / 3;
    final dashLength = segmentLength * 0.7;
    final dynamicOffset = offset + (t * 10);
    final dashPath = Path();

    for (int i = 0; i < 3; i++) {
      double startPosition = (i * segmentLength + dynamicOffset + (i * 5)) % totalLength;
      final extract = metric.extractPath(startPosition, startPosition + dashLength);
      dashPath.addPath(extract, Offset.zero);

      if (i == 1) {
        final midPoint = metric.extractPath(startPosition + dashLength / 2, startPosition + dashLength / 2 + 1);
        dashPath.addPath(midPoint, Offset.zero);
      }
    }

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.4),
          color.withOpacity(0.8),
          color.withOpacity(0.4),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.7
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(dashPath, paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(dashPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}