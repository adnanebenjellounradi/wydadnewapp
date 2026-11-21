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
import 'publish_resale_screen.dart';

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
  final int? selectedTicketId;
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
    this.selectedTicketId,
    required this.isReceiver,
  }) : super(key: key);

  @override
  _SwipeTicketsPageState createState() => _SwipeTicketsPageState();
}

class _SwipeTicketsPageState extends State<SwipeTicketsPage>
    with SingleTickerProviderStateMixin {
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
  final Color gold = const Color(0xFFFEE15A);
  final Color amber = const Color(0xFFFFC97A);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _filteredTickets = _filterTickets(widget.tickets);

    int validIndex = 0;
    if (widget.selectedTicketId != null) {
      final idx = _filteredTickets
          .indexWhere((t) => t["id"] == widget.selectedTicketId);
      if (idx >= 0) validIndex = idx;
    } else if (widget.initialTicketIndex < _filteredTickets.length) {
      validIndex = widget.initialTicketIndex;
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

      if (widget.event["date_qr_code"] != null &&
          widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime =
        DateTime.parse(widget.event["date_qr_code"].toString());
        return nowLocal.isBefore(qrCodeDateTime);
      }

      DateTime sixHoursBefore = eventLocal.subtract(const Duration(hours: 5));
      return nowLocal.isBefore(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  void _toggleTicketSelection(int ticketId, String eventDate, int ticketStatus,
      int isTransferable, int transferStatus, int orderTransferStatus) {
    if (isTransferAllowed(eventDate, ticketStatus, isTransferable,
        transferStatus, orderTransferStatus) &&
        canStillTransfer(eventDate)) {
      setState(() {
        if (_selectedTickets.contains(ticketId)) {
          _selectedTickets.remove(ticketId);
        } else {
          _selectedTickets.add(ticketId);
        }
        _showTransferButton = _selectedTickets.isNotEmpty;
      });
    }
  }

  Future<String?> _scanQRCodeForEmail() async {
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
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
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

  Future<Map<String, dynamic>?> _verifyAndGetCustomerId(
      String scannedEmail) async {
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
        if (customer["organization_id"].toString() ==
            widget.currentOrganizationId.toString()) {
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
          _snack(l10n.invitationSentSuccess, warn: true);
        }
        return null;
      }
    } else {
      _snack(l10n.errorCheckingEmail, error: true);
      return null;
    }
  }

  Future<bool?> _showInviteDialog(String scannedEmail) async {
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
                            Uri.parse(
                                "https://ticketing.ma/api/customer/send-invitation"),
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
        final confirmed =
        await _showFinalConfirmationModal(email, _selectedTickets.length);
        if (confirmed == true) {
          await _performBulkTransfer(
              _selectedTickets.toList(), customerId, email);
        }
      }
    }
  }

  Future<void> _performBulkTransfer(
      List<int> ticketIds, int customerId, String email) async {
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
              "🎉 ${ticketIds.length} ${l10n.ticketPlural} ${l10n.transferredSuccessfullyTo} $email");
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
                        prefixIcon: Icon(Icons.email,
                            color: Colors.white.withOpacity(0.6), size: 18),
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
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.14)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.14)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.6)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
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
                              child:
                              CircularProgressIndicator(color: gold),
                            ),
                          );
                          final result =
                          await _verifyAndGetCustomerId(scannedEmail);
                          Navigator.pop(context);
                          if (result != null &&
                              result['customerId'] != null) {
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
                          border: Border.all(
                              color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner,
                                size: 16, color: gold),
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
                                final result =
                                await _verifyAndGetCustomerId(email);
                                if (result != null &&
                                    result['customerId'] != null) {
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

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A060D), Color(0xFF1A0206)],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.14)),
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
          colors: [Color(0xFFB0141F), Color(0xFF860D16)],
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
        backgroundColor:
        error ? const Color(0xFFE5484D) : (warn ? amber : primary),
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

  @override
  Widget build(BuildContext context) {
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
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.9),
            radius: 1.1,
            colors: [
              Color(0xFFC8172A),
              Color(0x00C8172A),
            ],
            stops: [0.0, 0.62],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
              stops: [0.0, 0.30, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildEventTitle(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _filteredTickets.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[index];
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // Carte rouge avec flèches overlay
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildTicketCard(ticket),
                                  // Flèches de navigation
                                  Positioned(
                                    left: -6,
                                    child: _buildNavArrow(
                                      icon: Icons.chevron_left,
                                      enabled: _currentIndex > 0,
                                      onTap: () {
                                        if (_currentIndex > 0) {
                                          _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    right: -6,
                                    child: _buildNavArrow(
                                      icon: Icons.chevron_right,
                                      enabled: _currentIndex < _filteredTickets.length - 1,
                                      onTap: () {
                                        if (_currentIndex < _filteredTickets.length - 1) {
                                          _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Pagination
                              _buildPagination(),
                              const SizedBox(height: 14),
                              // Note personnelle
                              _buildPersonalNote(),
                              const SizedBox(height: 14),
                              // Boutons d'action
                              _buildActionButtons(),
                              const SizedBox(height: 20),
                              // Pied de page
                              Text(
                                "Présentez ce code à l'entrée. Luminosité augmentée automatiquement.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  fontFamily: 'Inter',
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Calcul du temps restant avant le match (converti en j/h/min)
    String? countdown;
    try {
      final eventDate = DateTime.parse(widget.event["date"]);
      final now = DateTime.now();
      if (now.isBefore(eventDate)) {
        final diff = eventDate.difference(now);

        if (diff.inDays > 0) {
          // Ex: "Coup d'envoi dans 2 j 5 h"
          countdown = "Coup d'envoi dans ${diff.inDays} j ${diff.inHours.remainder(24)} h";
        } else if (diff.inHours > 0) {
          // Ex: "Coup d'envoi dans 3 h 33"
          countdown = "Coup d'envoi dans ${diff.inHours} h ${diff.inMinutes.remainder(60)}";
        } else if (diff.inMinutes > 0) {
          // Ex: "Coup d'envoi dans 45 min"
          countdown = "Coup d'envoi dans ${diff.inMinutes} min";
        } else {
          countdown = "Coup d'envoi imminent";
        }
      }
    } catch (_) {}

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
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          if (countdown != null)
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFF5CD52).withOpacity(0.14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5CD52),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    countdown,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5CD52),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEventTitle() {
    final name = widget.event["name"]?.toString() ?? "";
    final date = _formatDateShort(widget.event["date"]);
    final address = widget.event["address"]?.toString() ?? "";

    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$date · $address",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final ticketData = ticket["ticket_data"];
    final ticketStatus = ticket["status"];
    final ticketNumber = ticket["ticket_number"];
    final transferStatus = ticket["transfer_status"] ?? 20;
    final isTransferable = widget.isTransferable;

    final category = widget.category ??
        (widget.ticket["name"]?.toString() ?? "");
    final holder = widget.orderData["customer_name"]?.toString() ?? "";

    final canShowQR = isTransferable != 0 &&
        shouldShowQRCode(widget.event["date"]) &&
        widget.isQrCode != 0 &&
        ticketStatus != 1 &&
        ticketStatus != 2 &&
        ticketStatus != 3 &&
        !isEventEnded(widget.event["date"]);

    Widget qrBlock;
    if (isEventEnded(widget.event["date"])) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.event_busy,
        title: l10n.eventEnded,
      );
    } else if (isTransferable == 0) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.block,
        title: l10n.qrCodeNotAuthorized,
      );
    } else if (ticketStatus == 2) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.confirmation_number,
        title: l10n.ticketAlreadyTransferred,
      );
    } else if (ticketStatus == 1) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.confirmation_number,
        title: l10n.usePhysicalTicket,
      );
    } else if (widget.isReceiver && transferStatus == 0) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.pending_actions,
        title: l10n.receivedTransferPending,
      );
    } else if (!shouldShowQRCode(widget.event["date"])) {
      final remaining = getTimeRemaining(widget.event["date"]);
      qrBlock = _qrCountdownBlock(remaining);
    } else if (widget.isQrCode == 0) {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.qr_code,
        title: l10n.qrCodeNotAvailableForCategory,
      );
    } else if (canShowQR) {
      qrBlock = _buildQRCodeContent(
          ticketNumber ?? "", ticketStatus ?? 0, widget.event["date"]);
    } else {
      qrBlock = _qrPlaceholderMessage(
        icon: Icons.qr_code,
        title: l10n.qrCodeWillAppearBeforeMatch,
      );
    }

    final showAcceptReject = widget.isReceiver && transferStatus == 0;
    final hasSeatingData = _hasTicketData(ticketData);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA8161F),
            Color(0xFF7A0D17),
            Color(0xFF4A0710),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 50,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -80,
              top: -110,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  // En-tête centré : CATÉGORIE + Titulaire
                  Column(
                    children: [

                      Text(
                        category.toUpperCase(),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$holder · titulaire",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.78),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bloc QR / message
                  qrBlock,
                  // Grille de placement
                  if (hasSeatingData) ...[
                    const SizedBox(height: 12),
                    _buildSeatingGrid(ticketData),
                  ],
                  if (showAcceptReject) ...[
                    const SizedBox(height: 14),
                    _buildAcceptRejectRow(ticket),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          color: const Color(0xFF120104).withOpacity(0.82),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }

  Widget _qrPlaceholderMessage({
    required IconData icon,
    required String title,
  }) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF07060F).withOpacity(0.35),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrCountdownBlock(String remaining) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF07060F).withOpacity(0.35),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 34, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                l10n.qrCodeWillAppearBeforeMatch,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Disponible dans $remaining",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatingGrid(Map<String, dynamic>? ticketData) {
    final porte = ticketData?["porte"]?.toString() ?? "—";
    final access = ticketData?["access"]?.toString() ?? "—";
    final bloc = ticketData?["secteur"]?.toString() ?? "—";
    final place = ticketData?["place"]?.toString() ?? "—";

    Widget item(String label, String value) {
      return Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.72),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF07060F).withOpacity(0.28),
      ),
      child: Row(
        children: [
          Expanded(child: item("PORTE", porte)),
          Expanded(child: item("ACCÈS", access)),
          Expanded(child: item("BLOC", bloc)),
          Expanded(child: item("PLACE", place)),
        ],
      ),
    );
  }

  Widget _buildAcceptRejectRow(Map<String, dynamic> ticket) {
    final id = ticket["id"];
    final ticketId = id is int ? id : int.tryParse(id.toString()) ?? 0;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _rejectTransfer(ticketId),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.refuse.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _acceptTransfer(ticketId),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3CA55C), Color(0xFF1E7A38)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.accept.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    final total = _filteredTickets.length;
    return Column(
      children: [
        Text(
          "Billet ${_currentIndex + 1} / $total",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (index) {
            final isActive = index == _currentIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive ? gold : Colors.white.withOpacity(0.3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPersonalNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline, size: 16, color: Color(0xFFFFC97A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Chaque billet est individuel et donne accès à une seule personne. Chaque enfant accompagné doit avoir son propre billet.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.5,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canTransfer = _selectedTickets.isNotEmpty;
    final canResell = _selectedTickets.isNotEmpty;

    return Row(
      children: [
        // ─── Bouton Transférer ───
        Expanded(
          child: GestureDetector(
            onTap: canTransfer ? _showBulkTransferModal : null,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: canTransfer ? Colors.white : Colors.white.withOpacity(0.85),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send,
                      size: 17,
                      color: canTransfer
                          ? primary
                          : primary.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text(
                    canTransfer
                        ? "${l10n.transfer.toUpperCase()} ${_selectedTickets.length}"
                        : "Transférer",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: canTransfer
                          ? primary
                          : primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ─── Bouton Revendre ───
        Expanded(
          child: GestureDetector(
            onTap: canResell ? _handleResellTap : null,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: canResell
                    ? const Color(0xFFFEE15A)
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: canResell
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 17,
                    color: canResell ? Colors.black87 : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canResell
                        ? "Revendre ${_selectedTickets.length}"
                        : "Revendre",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: canResell ? Colors.black87 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ═══════════════════════════════════════════════════════════
  // HANDLER : Bouton "Revendre"
  // ═══════════════════════════════════════════════════════════
  Future<void> _handleResellTap() async {
    if (_selectedTickets.isEmpty) return;

    // Vérification côté client : le match doit être dans > 2h
    // (l'API renverra 422 sinon, mais autant éviter un appel inutile)
    if (!_canStillResell(widget.event["date"]?.toString() ?? "")) {
      _snack(
        "La revente est fermée (moins de 2h avant le match).",
        error: true,
      );
      return;
    }

    // Calcul du prix original total pour pré-remplir le slider
    // On utilise le prix unitaire du ticket × nombre de billets sélectionnés
    final unitPrice = _getOriginalUnitPrice();
    final totalOriginalPrice = unitPrice * _selectedTickets.length;

    // Navigation vers PublishResaleScreen avec les IDs sélectionnés
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublishResaleScreen(
          token: widget.token,
          orderChildIds: _selectedTickets.toList(),
          originalPrice: totalOriginalPrice,
          matchName: widget.event["name"]?.toString() ?? "",
        ),
      ),
    );

    // Si la publication a réussi, on rafraîchit l'écran et on vide la sélection
    if (result == true && mounted) {
      setState(() {
        _selectedTickets.clear();
        _showTransferButton = false;
      });
      _snack("Vos billets sont maintenant en vente sur la Ticketplace !");
    }
  }

  // Vérifie qu'on est encore dans la fenêtre de revente (> 2h avant match)
  bool _canStillResell(String eventDate) {
    try {
      final event = DateTime.parse(eventDate.replaceAll('Z', ''));
      final now = DateTime.now();
      final cutoff = event.subtract(const Duration(hours: 2));
      return now.isBefore(cutoff);
    } catch (_) {
      return false;
    }
  }

  // Récupère le prix unitaire original depuis orderData ou ticket
  double _getOriginalUnitPrice() {
    // 1. Essaie depuis orderData (si dispo)
    final fromOrder = widget.orderData["ticket_price"] ??
        widget.orderData["price"] ??
        widget.orderData["unit_price"];
    if (fromOrder is num) return fromOrder.toDouble();
    if (fromOrder is String) {
      return double.tryParse(fromOrder) ?? 0.0;
    }

    // 2. Essaie depuis widget.ticket
    final fromTicket = widget.ticket["price"] ?? widget.ticket["resale_price"];
    if (fromTicket is num) return fromTicket.toDouble();
    if (fromTicket is String) {
      return double.tryParse(fromTicket) ?? 0.0;
    }

    // 3. Fallback : 0 (l'utilisateur saisira le prix dans PublishResaleScreen)
    return 0.0;
  }
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.9),
            radius: 1.1,
            colors: [Color(0xFFC8172A), Color(0x00C8172A)],
            stops: [0.0, 0.62],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
              stops: [0.0, 0.30, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeader(),
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
      ),
    );
  }

  Future<String?> _getDeviceIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceIdPrefrences');
  }

  Widget _buildQRCodeContent(
      String ticketNumber, int ticketStatus, String eventDate) {
    final ticket = widget.tickets[_currentIndex];
    final scanHistory = ticket["scan_history"];
    final hasBeenScanned =
        scanHistory != null && scanHistory["device_id"] != null;
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
            return const SizedBox(
              height: 176,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF5CD52)),
              ),
            );
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
                borderColor: borderColor,
                scanMessage: scanMessage,
              );
            } else {
              return _buildScannedFromOtherDeviceMessage(scanHistory);
            }
          }
          return _buildNormalQRCode(ticketNumber, ticketStatus, eventDate);
        },
      );
    } else {
      result = _buildNormalQRCode(ticketNumber, ticketStatus, eventDate);
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
        Color borderColor = const Color(0xFFA8161F),
        String? scanMessage,
      }) {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Effet de bordure rotative
          Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: 2 * math.pi,
                colors: [
                  Color(0xFFFEE15A),
                  Colors.transparent,
                  Color(0xFFFEE15A),
                  Colors.transparent,
                ],
                stops: [0.0, 0.3, 0.5, 0.8],
              ),
            ),
          ),
          // Bloc QR principal
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heure + point clignotant
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BlinkingDot(color: const Color(0xFFC8172A)),
                    const SizedBox(width: 7),
                    Text(
                      timeString,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1,
                        color: Color(0xFFC8172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // QR Code
                QrImageView(
                  data: ticketNumber,
                  size: 210,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF07060F),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF07060F),
                  ),
                ),
                if (scanMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedFromOtherDeviceMessage(
      Map<String, dynamic> scanHistory) {
    final scanDate = scanHistory["enter_at"] != null
        ? _formatDateTime(scanHistory["enter_at"])
        : l10n.unknownDate;

    return Container(
      height: 176,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5484D).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE5484D).withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 40, color: Color(0xFFE5484D)),
          const SizedBox(height: 10),
          Text(
            l10n.ticketAlreadyScanned,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "$scanDate · ${l10n.otherDevice}",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

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

  String _formatDateShort(String? rawDate) {
    if (rawDate == null) return "";
    try {
      DateTime parsed = DateTime.parse(rawDate);
      const days = ["Lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam.", "Dim."];
      final dayLabel = days[parsed.weekday - 1];
      final dd = parsed.day.toString().padLeft(2, '0');
      final mm = parsed.month.toString().padLeft(2, '0');
      final hh = parsed.hour.toString().padLeft(2, '0');
      final mn = parsed.minute.toString().padLeft(2, '0');
      return "$dayLabel $dd/$mm · $hh:$mn";
    } catch (e) {
      return rawDate;
    }
  }

  bool shouldShowQRCode(String eventDate) {
    try {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 1));
      DateTime eventDateTime = DateTime.parse(eventDate).toUtc();

      if (widget.event["date_qr_code"] != null &&
          widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime =
        DateTime.parse(widget.event["date_qr_code"].toString()).toUtc();
        DateTime oneHourAfterMatch =
        eventDateTime.add(const Duration(hours: 1));
        bool isAfterOrAtStartTime =
            now.isAfter(qrCodeDateTime) || now.isAtSameMomentAs(qrCodeDateTime);
        bool isBeforeEndTime = now.isBefore(oneHourAfterMatch);
        return isAfterOrAtStartTime && isBeforeEndTime;
      } else {
        DateTime sixHoursBefore =
        eventDateTime.subtract(const Duration(hours: 5));
        return now.isAfter(sixHoursBefore);
      }
    } catch (e) {
      return false;
    }
  }

  String getTimeRemaining(String eventDate) {
    try {
      if (widget.event["date_qr_code"] != null &&
          widget.event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime =
        DateTime.parse(widget.event["date_qr_code"].toString());
        DateTime eventDateTime = DateTime.parse(eventDate);
        DateTime oneHourAfterMatch = eventDateTime.add(const Duration(hours: 1));
        DateTime now = DateTime.now();

        if (now.millisecondsSinceEpoch <
            qrCodeDateTime.millisecondsSinceEpoch) {
          Duration remaining = qrCodeDateTime.difference(now);
          return _formatDuration(remaining);
        } else if (now.millisecondsSinceEpoch <
            eventDateTime.millisecondsSinceEpoch) {
          Duration remaining = eventDateTime.difference(now);
          return _formatDuration(remaining);
        } else if (now.millisecondsSinceEpoch <
            oneHourAfterMatch.millisecondsSinceEpoch) {
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
        DateTime oneHourAfterStart =
        eventDateTime.add(const Duration(hours: 1));
        if (now.millisecondsSinceEpoch <
            oneHourAfterStart.millisecondsSinceEpoch) {
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
      return l10n.invalidDate;
    }
  }

  String _formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return "${days}j ${hours}h ${minutes}min";
    } else if (hours > 0) {
      return "${hours}h ${minutes}min";
    } else if (minutes > 0) {
      return "${minutes}min ${seconds}s";
    } else {
      return "${seconds}s";
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
      return nowLocal.millisecondsSinceEpoch >
          eventLocal.millisecondsSinceEpoch;
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
    final place = ticketData["place"]?.toString().trim() ?? "";
    return porte.isNotEmpty ||
        access.isNotEmpty ||
        secteur.isNotEmpty ||
        place.isNotEmpty;
  }

  Future<bool?> _showFinalConfirmationModal(String email, int ticketCount) async {
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
                child: const Icon(Icons.swap_horiz,
                    color: Color(0xFFF5CD52), size: 34),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFFF5CD52),
                  ),
                  textAlign: TextAlign.center,
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
          _snack("${data["message"] ?? l10n.acceptTransferError}",
              error: true);
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
          _snack("${data["message"] ?? l10n.rejectTransferError}",
              error: true);
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

class _BlinkingDot extends StatefulWidget {
  final Color color;
  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}