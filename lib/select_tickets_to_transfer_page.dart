import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
// Billet affiché dans la bottom sheet / la confirmation
// ═══════════════════════════════════════════════════════════
class _TicketItem {
  final int id;
  final String label; // "Billet 1 · Virage Nord"
  final String orderLabel; // "Commande #A3107"
  final String seat; // "Porte 4 · Bloc 3.1 · Place C08"

  _TicketItem({
    required this.id,
    required this.label,
    required this.orderLabel,
    required this.seat,
  });

  String get sub => seat.isNotEmpty ? '$orderLabel · $seat' : orderLabel;
}

class SelectTicketsToTransferPage extends StatefulWidget {
  final String token;
  final int eventId;
  final String? currentOrganizationId;
  final String eventName;
  final String eventDate;
  final List<dynamic> orders;
  final String? userEmail;

  const SelectTicketsToTransferPage({
    Key? key,
    required this.token,
    required this.eventId,
    this.currentOrganizationId,
    required this.eventName,
    required this.eventDate,
    required this.orders,
    this.userEmail,
  }) : super(key: key);

  @override
  State<SelectTicketsToTransferPage> createState() =>
      _SelectTicketsToTransferPageState();
}

class _SelectTicketsToTransferPageState
    extends State<SelectTicketsToTransferPage> {
  static const Color primary = Color(0xFFA8161F);
  static const Color gold = Color(0xFFF5CD52);
  static const Color amber = Color(0xFFFFC97A);
  static const Color yellow = Color(0xFFFEE15A);

  final Set<int> _selected = {};

  /// Commandes rechargées depuis l'API (mêmes données que TicketsPage)
  List<Map<String, dynamic>> _freshOrders = [];
  final Map<int, _TicketItem> _items = {};
  bool _loading = true;
  bool _busy = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadFreshOrders();
  }

  Future<void> _loadFreshOrders() async {
    setState(() => _loading = true);
    final refreshed = <Map<String, dynamic>>[];
    for (final o in widget.orders) {
      final id = o["id"];
      final orderId = id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0;
      if (orderId == 0) continue;

      try {
        final res = await http.get(
          Uri.parse("https://ticketing.ma/api/customer/orders/$orderId"),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-Type": "application/json",
          },
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data["success"] == true && data["data"] != null) {
            refreshed.add(Map<String, dynamic>.from(data["data"]));
            continue;
          }
        }
      } catch (_) {}
      // fallback : utilise les données passées
      refreshed.add(Map<String, dynamic>.from(o));
    }
    if (!mounted) return;
    _buildItems(refreshed);
    setState(() {
      _freshOrders = refreshed;
      _loading = false;
    });
  }

  /// Prépare les libellés "Billet N · Catégorie" utilisés par E8 / E8b
  void _buildItems(List<Map<String, dynamic>> orders) {
    _items.clear();
    int counter = 1;
    for (final order in orders) {
      final children = order["order_child"] as List<dynamic>? ?? [];
      final cat = order["ticket"]?["name"]?.toString() ?? '';
      final oid = order["order_id"]?.toString();
      final raw = (oid != null && oid.isNotEmpty) ? oid : '#${order["id"]}';
      final orderLabel = 'Commande ${raw.startsWith('#') ? raw : '#$raw'}';

      for (final child in children) {
        final id = _ticketId(child);
        if (id == 0) continue;
        final data = child["ticket_data"] ?? {};
        final parts = <String>[];
        final porte = data["porte"]?.toString() ?? '';
        final secteur = data["secteur"]?.toString() ?? '';
        final place = data["place"]?.toString() ?? '';
        if (porte.isNotEmpty) parts.add('Porte $porte');
        if (secteur.isNotEmpty) parts.add('Bloc $secteur');
        if (place.isNotEmpty) parts.add('Place $place');

        _items[id] = _TicketItem(
          id: id,
          label: cat.isNotEmpty ? 'Billet $counter · $cat' : 'Billet $counter',
          orderLabel: orderLabel,
          seat: parts.join(' · '),
        );
        counter++;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RÈGLES DE TRANSFERT — COPIE EXACTE DE TicketsPage
  // ═══════════════════════════════════════════════════════════

  bool shouldShowQRCode(String eventDate, Map<String, dynamic> event) {
    try {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 1));
      DateTime eventDateTime = DateTime.parse(eventDate).toUtc();

      if (event["date_qr_code"] != null &&
          event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime =
        DateTime.parse(event["date_qr_code"].toString()).toUtc();
        DateTime oneHourAfterMatch =
        eventDateTime.add(const Duration(hours: 1));
        bool isAfterOrAtStartTime =
            now.isAfter(qrCodeDateTime) || now.isAtSameMomentAs(qrCodeDateTime);
        bool isBeforeEndTime = now.isBefore(oneHourAfterMatch);
        return isAfterOrAtStartTime && isBeforeEndTime;
      }
      DateTime sixHoursBefore =
      eventDateTime.subtract(const Duration(hours: 5));
      return now.isAfter(sixHoursBefore);
    } catch (e) {
      return false;
    }
  }

  bool canStillTransfer(String rawDate, Map<String, dynamic> event) {
    try {
      String localDateString = rawDate.replaceAll('Z', '');
      DateTime eventLocal = DateTime.parse(localDateString);
      DateTime nowLocal = DateTime.now();

      if (event["date_qr_code"] != null &&
          event["date_qr_code"].toString().isNotEmpty) {
        DateTime qrCodeDateTime =
        DateTime.parse(event["date_qr_code"].toString());
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

  bool _isTicketSelectable(dynamic child, dynamic order) {
    final event = order["event"] as Map<String, dynamic>?;
    if (event == null) return false;
    final eventDate = event["date"]?.toString() ?? '';
    if (eventDate.isEmpty) return false;

    final ticketStatus = (child["status"] is int)
        ? child["status"] as int
        : int.tryParse(child["status"]?.toString() ?? '0') ?? 0;
    final transferStatus = (child["transfer_status"] is int)
        ? child["transfer_status"] as int
        : int.tryParse(child["transfer_status"]?.toString() ?? '20') ?? 20;
    final orderTransferStatus = (order["transfer_status"] is int)
        ? order["transfer_status"] as int
        : int.tryParse(order["transfer_status"]?.toString() ?? '20') ?? 20;
    final isTransferable = (order["ticket"]?["is_transferable"] is int)
        ? order["ticket"]["is_transferable"] as int
        : int.tryParse(
        order["ticket"]?["is_transferable"]?.toString() ?? '0') ??
        0;

    return isTransferAllowed(
      eventDate,
      ticketStatus,
      isTransferable,
      transferStatus,
      orderTransferStatus,
      event,
    );
  }

  List<dynamic> _availableTickets(dynamic order) {
    final children = order["order_child"] as List<dynamic>? ?? [];
    return children.where((c) => _isTicketSelectable(c, order)).toList();
  }

  int _ticketId(dynamic child) {
    final id = child["id"];
    return id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0;
  }

  void _toggleAll(dynamic order, bool select) {
    final avail = _availableTickets(order);
    setState(() {
      for (final t in avail) {
        final id = _ticketId(t);
        if (id == 0) continue;
        if (select) {
          _selected.add(id);
        } else {
          _selected.remove(id);
        }
      }
    });
  }

  void _toggleOne(dynamic child, dynamic order) {
    if (!_isTicketSelectable(child, order)) return;
    final id = _ticketId(child);
    if (id == 0) return;
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS UI
  // ═══════════════════════════════════════════════════════════

  void _snack(String message, {bool error = false, bool warn = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'urbanist')),
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
              const CircularProgressIndicator(color: gold),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'urbanist',
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

  BoxDecoration _dialogDecoration() => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3A060D), Color(0xFF1A0206)],
    ),
    border: Border.all(color: Colors.white.withOpacity(0.16)),
    boxShadow: const [
      BoxShadow(
          color: Color(0x99000000), blurRadius: 60, offset: Offset(0, 30)),
    ],
  );

  Widget _outlineButton(String label) => Container(
    height: 48,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white.withOpacity(0.08),
      border: Border.all(color: Colors.white.withOpacity(0.18)),
    ),
    child: Center(
      child: Text(label,
          style: TextStyle(
              fontFamily: 'urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9))),
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // API : vérification du destinataire
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> _verifyAndGetCustomerId(String email) async {
    if (!email.contains("@")) {
      _snack(l10n.invalidEmailFormat, error: true);
      return null;
    }
    if (widget.userEmail != null &&
        email.trim().toLowerCase() == widget.userEmail!.trim().toLowerCase()) {
      _snack("Vous ne pouvez pas vous transférer des billets à vous-même.",
          error: true);
      return null;
    }

    try {
      final uri = Uri.parse("https://ticketing.ma/api/customer/search")
          .replace(queryParameters: {"email": email});
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["data"] != null) {
          final customer = data["data"];
          if (customer["organization_id"].toString() ==
              widget.currentOrganizationId.toString()) {
            return {'customerId': customer["id"], 'email': email};
          }
          _snack(l10n.userNotInOrganization, error: true);
          return null;
        }
        await _showInviteDialog(email);
        return null;
      }
      _snack(l10n.errorCheckingEmail, error: true);
      return null;
    } catch (e) {
      _snack("${l10n.error}: $e", error: true);
      return null;
    }
  }

  Future<void> _showInviteDialog(String email) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => Dialog(
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
                child:
                const Icon(Icons.person_add_alt_1, color: amber, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.userNotFound,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                "${l10n.userNotFoundMessage} $email,\n${l10n.inviteQuestion}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: _outlineButton(l10n.cancel),
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
                            body: jsonEncode({"email": email}),
                          );
                          Navigator.pop(ctx);
                          _snack(l10n.invitationSentSuccess);
                        } catch (e) {
                          Navigator.pop(ctx);
                          _snack("${l10n.invitationError}: $e", error: true);
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                              colors: [Color(0xFFD11A2A), Color(0xFFA8161F)]),
                        ),
                        child: Center(
                          child: Text(l10n.invite,
                              style: const TextStyle(
                                  fontFamily: 'urbanist',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
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

  // ═══════════════════════════════════════════════════════════
  // Scan QR
  // ═══════════════════════════════════════════════════════════

  Future<String?> _scanQRCode() async {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        final controller = MobileScannerController();
        bool done = false;
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
                    Text(l10n.scanQRCode,
                        style: const TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        controller.dispose();
                        Navigator.pop(ctx);
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
                      controller: controller,
                      onDetect: (capture) {
                        if (done) return;
                        for (final b in capture.barcodes) {
                          if (b.rawValue != null) {
                            done = true;
                            controller.dispose();
                            Navigator.pop(ctx, b.rawValue!);
                            return;
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(l10n.positionQRCodeInFrame,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Flux : Continuer → E8 → E8b → API
  // ═══════════════════════════════════════════════════════════

  Future<void> _continue() async {
    if (_selected.isEmpty || _busy) return;

    String initialEmail = '';
    while (mounted) {
      final chosen = _selected
          .where(_items.containsKey)
          .map((id) => _items[id]!)
          .toList();

      // E8 — bottom sheet "Transférer des billets"
      final sheetResult = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: const Color(0x99080002),
        builder: (_) => _TransferSheet(
          tickets: chosen,
          initialEmail: initialEmail,
          onScan: _scanQRCode,
          onVerify: _verifyAndGetCustomerId,
          primary: primary,
          yellow: yellow,
        ),
      );

      if (sheetResult == null) return; // fermé / "Modifier" → retour sélection

      final email = sheetResult['email'] as String;
      final customerId = sheetResult['customerId'];
      final ids = List<int>.from(sheetResult['ids'] as List);
      setState(() {
        _selected
          ..clear()
          ..addAll(ids);
      });

      // E8b — confirmation irréversible
      final confirmed = await _showConfirmDialog(email, ids);
      if (confirmed == true) {
        await _performTransfer(ids, customerId, email);
        return;
      }
      initialEmail = email; // Annuler → retour à E8
    }
  }

  Future<bool?> _showConfirmDialog(String email, List<int> ids) {
    final chosen =
    ids.where(_items.containsKey).map((id) => _items[id]!).toList();
    final n = chosen.length;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xB8080002),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: _dialogDecoration(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: amber.withOpacity(0.14),
                    border: Border.all(color: amber.withOpacity(0.35)),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: amber, size: 28),
                ),
                const SizedBox(height: 14),
                const Text('Confirmer le transfert ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.8)),
                    children: [
                      const TextSpan(text: 'Vous allez envoyer '),
                      TextSpan(
                          text: '$n ${n > 1 ? 'billets' : 'billet'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' à\n'),
                      TextSpan(
                          text: email,
                          style: const TextStyle(
                              color: yellow, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6),
                        child: Text(
                          widget.eventName.toUpperCase() +
                              (widget.eventDate.isNotEmpty
                                  ? ' · ${widget.eventDate}'
                                  : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                      ...chosen.map(_confirmRow),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: amber.withOpacity(0.10),
                    border: Border.all(color: amber.withOpacity(0.30)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.info_outline,
                            size: 16, color: amber),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                fontFamily: 'urbanist',
                                fontSize: 12,
                                height: 1.45,
                                color: Color(0xFFFFE2B8)),
                            children: [
                              TextSpan(
                                  text: 'Action irréversible. ',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w800)),
                              TextSpan(
                                  text:
                                  "Une fois envoyés, vous ne pourrez plus annuler ce transfert. Seul le destinataire pourra l'accepter ou le refuser."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text('Confirmer le transfert',
                          style: TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: primary)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx, false),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: Center(
                      child: Text('Annuler',
                          style: TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8))),
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

  Widget _confirmRow(_TicketItem t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.white.withOpacity(0.10),
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                if (t.seat.isNotEmpty)
                  Text(t.seat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performTransfer(
      List<int> ids, dynamic customerId, String email) async {
    setState(() => _busy = true);
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
            {"customer_id": customerId, "order_child_ids": ids}
          ]
        }),
      );
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          _snack(
              "🎉 ${ids.length} ${l10n.ticketPlural} ${l10n.transferredSuccessfullyTo} $email");
          if (mounted) Navigator.pop(context, true);
          return;
        }
        _snack("${data["message"] ?? l10n.transferError}", error: true);
      } else {
        _snack("${l10n.serverError}: ${response.statusCode}", error: true);
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _snack("${l10n.error}: $e", error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD (E5b)
  // ═══════════════════════════════════════════════════════════

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.selectTicketsHint,
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _loading
                    ? const Center(
                    child: CircularProgressIndicator(color: gold))
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    ..._freshOrders.map(_buildOrderSection),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        l10n.unselectableNotice,
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
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
            onTap: () => Navigator.maybePop(context, false),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.transferTicketsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.eventName.isNotEmpty
                      ? '${widget.eventName} · ${widget.eventDate}'
                      : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(dynamic order) {
    final avail = _availableTickets(order);
    final allIds = avail.map(_ticketId).where((id) => id != 0).toSet();
    final allSelected = allIds.isNotEmpty && allIds.every(_selected.contains);
    final someSelected = allIds.any(_selected.contains);
    final orderChildren = order["order_child"] as List<dynamic>? ?? [];
    final orderRef = order["order_id"] ?? '#${order["id"]}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: avail.isEmpty ? null : () => _toggleAll(order, !allSelected),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  _CheckBox(
                    checked: allSelected,
                    partial: someSelected && !allSelected,
                    disabled: avail.isEmpty,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.order} $orderRef',
                          style: const TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${order["ticket"]?["name"] ?? ""} · '
                              '${orderChildren.length} '
                              '${orderChildren.length > 1 ? l10n.ticketPlural : l10n.ticket}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    avail.isEmpty
                        ? l10n.unavailable
                        : (allSelected ? l10n.deselectAll : l10n.selectAll),
                    style: TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: avail.isEmpty
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...orderChildren.map((child) => _buildTicketRow(child, order)),
        ],
      ),
    );
  }

  Widget _buildTicketRow(dynamic child, dynamic order) {
    final id = _ticketId(child);
    final isAvail = _isTicketSelectable(child, order);
    final checked = _selected.contains(id);
    final data = child["ticket_data"] ?? {};
    final seat = data["place"] != null
        ? 'Porte ${data["porte"] ?? ""} · Bloc ${data["secteur"] ?? ""} · Place ${data["place"] ?? ""}'
        : '';
    final ticketName = order["ticket"]?["name"]?.toString() ?? '';

    String? disabledLabel;
    if (!isAvail) {
      final status = (child["status"] is int)
          ? child["status"] as int
          : int.tryParse(child["status"]?.toString() ?? '0') ?? 0;
      final transferStatus = (child["transfer_status"] is int)
          ? child["transfer_status"] as int
          : int.tryParse(child["transfer_status"]?.toString() ?? '20') ?? 20;

      if (transferStatus == 0) {
        disabledLabel = l10n.inPendingLabel;
      } else if (status == 2 || transferStatus == 1) {
        disabledLabel = l10n.transferredLabel;
      } else if (status == 3) {
        disabledLabel = l10n.statusUsed;
      } else if (status == 1) {
        disabledLabel = l10n.statusPrinted;
      } else {
        disabledLabel = l10n.unavailable;
      }
    }

    return InkWell(
      onTap: isAvail ? () => _toggleOne(child, order) : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          color: checked ? Colors.white.withOpacity(0.07) : null,
        ),
        child: Row(
          children: [
            _CheckBox(checked: checked, disabled: !isAvail),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.ticket} ${child["id"] ?? ""} · $ticketName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(isAvail ? 1 : 0.5),
                    ),
                  ),
                  if (seat.isNotEmpty)
                    Text(
                      seat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            if (disabledLabel != null)
              Text(
                disabledLabel,
                style: const TextStyle(
                  fontFamily: 'urbanist',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: amber,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final count = _selected.length;
    final hasSelection = count > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xEB120104),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.selectionLabel,
                style: TextStyle(
                  fontFamily: 'urbanist',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
              Text(
                '$count ${count > 1 ? l10n.ticketPlural : l10n.ticket}',
                style: const TextStyle(
                  fontFamily: 'urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: hasSelection ? _continue : null,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: hasSelection
                    ? Colors.white
                    : Colors.white.withOpacity(0.10),
              ),
              child: Center(
                child: Text(
                  hasSelection
                      ? l10n.continueLabel
                      : l10n.selectAtLeastOneTicket,
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                    hasSelection ? primary : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool checked;
  final bool partial;
  final bool disabled;

  const _CheckBox({
    this.checked = false,
    this.partial = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = disabled
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.4);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: checked
            ? Colors.white
            : (partial ? Colors.white.withOpacity(0.35) : Colors.transparent),
        border:
        checked || partial ? null : Border.all(color: borderColor, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check, size: 13, color: Color(0xFFA8161F))
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// E8 — Bottom sheet "Transférer des billets"
// ═══════════════════════════════════════════════════════════
class _TransferSheet extends StatefulWidget {
  final List<_TicketItem> tickets;
  final String initialEmail;
  final Future<String?> Function() onScan;
  final Future<Map<String, dynamic>?> Function(String) onVerify;
  final Color primary;
  final Color yellow;

  const _TransferSheet({
    required this.tickets,
    required this.initialEmail,
    required this.onScan,
    required this.onVerify,
    required this.primary,
    required this.yellow,
  });

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  late final TextEditingController _email;
  late Set<int> _checked;
  dynamic _customerId;
  String? _verifiedEmail;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
    _checked = widget.tickets.map((t) => t.id).toSet();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await widget.onScan();
    if (scanned == null) return;
    setState(() => _checking = true);
    final result = await widget.onVerify(scanned.trim());
    if (!mounted) return;
    setState(() => _checking = false);
    if (result != null && result['customerId'] != null) {
      setState(() {
        _email.text = scanned.trim();
        _customerId = result['customerId'];
        _verifiedEmail = scanned.trim();
      });
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (_checked.isEmpty || _checking) return;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.enterValidEmail),
        backgroundColor: const Color(0xFFE5484D),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    if (_customerId == null || _verifiedEmail != email) {
      setState(() => _checking = true);
      final result = await widget.onVerify(email);
      if (!mounted) return;
      setState(() => _checking = false);
      if (result == null || result['customerId'] == null) return;
      _customerId = result['customerId'];
      _verifiedEmail = email;
    }

    Navigator.pop(context, {
      'email': email,
      'customerId': _customerId,
      'ids': _checked.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = _checked.length;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A060D), Color(0xFF1A0206)],
          ),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12))),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.24),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text('Transférer des billets',
                        style: TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.08),
                      ),
                      child:
                      const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Transfert gratuit à un proche. Une fois envoyé, il ne peut plus être annulé : seul le destinataire peut l'accepter ou le refuser.",
                style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.72)),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Billets à transférer',
                      style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.86))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Modifier',
                        style: TextStyle(
                            fontFamily: 'urbanist',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.yellow)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.tickets.map(_ticketRow),
              const SizedBox(height: 16),
              Text('E-mail du destinataire',
                  style: TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.86))),
              const SizedBox(height: 6),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                cursorColor: Colors.white,
                onChanged: (_) {
                  // e-mail modifié → il faudra re-vérifier le destinataire
                  _customerId = null;
                  _verifiedEmail = null;
                },
                style: const TextStyle(
                    fontFamily: 'urbanist', fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'exemple@mail.com',
                  hintStyle: TextStyle(
                      fontFamily: 'urbanist',
                      color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: Colors.white.withOpacity(0.12), height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('ou',
                          style: TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5))),
                    ),
                    Expanded(
                        child: Divider(
                            color: Colors.white.withOpacity(0.12), height: 1)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _scan,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.26)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Scanner le QR code de son profil',
                          style: TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: n == 0 ? null : _submit,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                    n == 0 ? Colors.white.withOpacity(0.10) : Colors.white,
                  ),
                  child: Center(
                    child: _checking
                        ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: widget.primary),
                    )
                        : Text(
                      n == 0
                          ? 'Sélectionnez un billet'
                          : 'Transférer $n ${n > 1 ? 'billets' : 'billet'}',
                      style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: n == 0
                              ? Colors.white30
                              : widget.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(_TicketItem t) {
    final on = _checked.contains(t.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (!_checked.remove(t.id)) _checked.add(t.id);
      }),
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(on ? 0.10 : 0.04),
          border: Border.all(
            color: on ? Colors.white : Colors.white.withOpacity(0.12),
            width: on ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: on ? Colors.white : Colors.transparent,
                border: on
                    ? null
                    : Border.all(
                    color: Colors.white.withOpacity(0.35), width: 2),
              ),
              child: on
                  ? const Icon(Icons.check, size: 14, color: Color(0xFF07060F))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(t.sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}