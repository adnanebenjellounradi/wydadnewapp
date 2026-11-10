import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'cmi_payment_ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'l10n/app_localizations.dart';

class AcheterTicketInEventPage extends StatefulWidget {
  final String token;
  final int eventId;
  final String? currentOrganizationId;

  const AcheterTicketInEventPage({
    Key? key,
    required this.token,
    required this.eventId,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  _AcheterTicketInEventPageState createState() =>
      _AcheterTicketInEventPageState();
}

class _AcheterTicketInEventPageState extends State<AcheterTicketInEventPage> {
  Map<String, dynamic>? event;
  bool isLoading = false;
  Map<int, int> ticketQuantities = {};
  bool _hasTicketsSelected = false;
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  bool _isCinValid = false;
  bool _isFullNameValid = false;

  final Color primary = const Color(0xFFA8161F);

  @override
  void initState() {
    super.initState();
    fetchEventDetails();

    _cinController.addListener(_validateCin);
    _fullNameController.addListener(_validateFullName);
  }

  @override
  void dispose() {
    _cinController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _validateCin() {
    final cin = _cinController.text.trim();
    setState(() {
      _isCinValid = RegExp(r'^[A-Z][A-Za-z0-9]{0,7}$').hasMatch(cin);
    });
  }

  void _validateFullName() {
    final fullName = _fullNameController.text.trim();
    setState(() {
      _isFullNameValid = fullName.length >= 4 &&
          RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(fullName) &&
          fullName.split(' ').length >= 2;
    });
  }

  bool get _allFieldsValid => _isCinValid && _isFullNameValid;

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return "${price.round()} MAD";
    }
    return "${price.toStringAsFixed(2)} MAD";
  }

  Future<void> fetchEventDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            "https://ticketing.ma/api/customer/events/${widget.eventId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            event = data["data"];
          });
        }
      }
    } catch (e) {
      print("Error fetching event details: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ SÉLECTION EXCLUSIVE : une seule catégorie à la fois
  /// - Si on augmente une catégorie → désélectionne toutes les autres
  /// - Si on met à 0 → désélectionne simplement cette catégorie
  void _updateTicketQuantity(int ticketId, int newQuantity) {
    setState(() {
      if (newQuantity > 0) {
        // Désélectionne toutes les autres catégories
        ticketQuantities.forEach((key, _) {
          if (key != ticketId) {
            ticketQuantities[key] = 0;
          }
        });
      }
      ticketQuantities[ticketId] = newQuantity;
      _hasTicketsSelected = ticketQuantities.values.any((q) => q > 0);
    });
  }

  List<Map<String, dynamic>> _getAvailableTickets() {
    if (event == null || event!["ticket"] == null) return [];
    final tickets = event!["ticket"];
    if (tickets is List) {
      return tickets
          .where((ticket) =>
      ticket is Map<String, dynamic> && ticket["is_available"] == true)
          .cast<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  Map<String, dynamic>? get _selectedTicket {
    final selected = ticketQuantities.entries.where((e) => e.value > 0);
    if (selected.isEmpty) return null;
    final entry = selected.first;
    return _getAvailableTickets()
        .firstWhere((t) => t["id"] == entry.key, orElse: () => {});
  }

  int get _totalQuantity =>
      ticketQuantities.values.fold(0, (a, b) => a + (b > 0 ? b : 0));

  double get _totalPrice {
    double total = 0;
    ticketQuantities.forEach((id, qty) {
      if (qty == 0) return;
      final t = _getAvailableTickets()
          .firstWhere((t) => t["id"] == id, orElse: () => {});
      if (t.isEmpty) return;
      final price = t["price"] is int
          ? (t["price"] as int).toDouble()
          : (t["price"] as num).toDouble();
      total += price * qty;
    });
    return total;
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && event == null) {
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (event == null) {
      return _buildErrorState(
        icon: Icons.error_outline,
        title: AppLocalizations.of(context)!.eventNotFound,
        subtitle: AppLocalizations.of(context)!.pleaseTryAgainLater,
      );
    }

    if (event!["is_closed"] == true) {
      return _buildErrorState(
        icon: Icons.event_busy,
        title: AppLocalizations.of(context)!.eventClosed,
        subtitle: AppLocalizations.of(context)!.eventClosedMessage,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final tickets = _getAvailableTickets();

    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.07),
                    border:
                    Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.buyTickets,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),

        // ── Bannière event ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: _buildEventBanner(),
        ),

        // ── Liste des catégories ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectNumberOfTickets,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.86),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                ...tickets.map((ticket) => _buildTicketRow(ticket)).toList(),
              ],
            ),
          ),
        ),

        // ── Bottom bar fixe ──
        if (_hasTicketsSelected) _buildBottomBar(),
      ],
    );
  }

  Widget _buildEventBanner() {
    final date = event!["date"] != null
        ? DateFormat("dd/MM/yyyy · HH:mm")
        .format(DateTime.parse(event!["date"]))
        : '';
    final address = event!["address"]?.toString() ?? '';
    final name = event!["name"]?.toString() ?? '';
    final image = event!["image"]?.toString();

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null && image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD11A2A), Color(0xFF6E0B12)],
                  ),
                ),
              ),
            // Gradient horizontal gauche → droite
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF1E0307).withOpacity(0.92),
                    const Color(0xFF1E0307).withOpacity(0.55),
                    const Color(0xFF1E0307).withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BILLETTERIE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date · $address',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(Map<String, dynamic> ticket) {
    final l10n = AppLocalizations.of(context)!;
    final ticketId = ticket["id"] is int
        ? ticket["id"] as int
        : int.tryParse(ticket["id"].toString()) ?? 0;
    final quantity = ticketQuantities[ticketId] ?? 0;
    final isSelected = quantity > 0;
    final maxPerOrder = ticket["ticket_per_order"] is int
        ? ticket["ticket_per_order"] as int
        : int.tryParse(ticket["ticket_per_order"].toString()) ?? 4;
    final price = ticket["price"] is int
        ? (ticket["price"] as int).toDouble()
        : (ticket["price"] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.12),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Ligne principale
          InkWell(
            onTap: () {
              if (isSelected) {
                // Clic sur la catégorie déjà sélectionnée → la désélectionne
                _updateTicketQuantity(ticketId, 0);
              } else {
                // Clic sur une autre catégorie → désélectionne l'ancienne + sélectionne celle-ci
                _updateTicketQuantity(ticketId, 1);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Radio dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 2),
                    ),
                    child: isSelected
                        ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary,
                        ),
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Nom + dispo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket["name"]?.toString() ?? l10n.ticket,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _availabilityLabel(ticket),
                          style: TextStyle(
                            fontSize: 12,
                            color: _availabilityColor(ticket),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prix
                  Text(
                    _formatPrice(price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Qty stepper inline (visible seulement si sélectionné)
          if (isSelected)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nombre de billets',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$maxPerOrder maximum par compte',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.25),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus
                        GestureDetector(
                          onTap: quantity > 1
                              ? () => _updateTicketQuantity(
                              ticketId, quantity - 1)
                              : null,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Colors.white.withOpacity(0.12),
                            ),
                            child: const Icon(Icons.remove,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        // Plus
                        GestureDetector(
                          onTap: quantity < maxPerOrder
                              ? () => _updateTicketQuantity(
                              ticketId, quantity + 1)
                              : null,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFB0141F),
                                  Color(0xFF860D16)
                                ],
                              ),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _availabilityLabel(Map<String, dynamic> ticket) {
    final availQty = ticket["available_quantity"];
    if (availQty == null) return "Disponible";
    final qty = availQty is int
        ? availQty
        : int.tryParse(availQty.toString()) ?? 0;
    if (qty == 0) return "Complet";
    if (qty <= 10) return "Quelques places";
    return "Disponible";
  }

  Color _availabilityColor(Map<String, dynamic> ticket) {
    final availQty = ticket["available_quantity"];
    final qty = availQty is int
        ? availQty
        : int.tryParse(availQty?.toString() ?? '0') ?? 0;
    if (qty == 0) return Colors.white.withOpacity(0.6);
    if (qty <= 10) return const Color(0xFFFFC97A);
    return Colors.white.withOpacity(0.65);
  }

  Widget _buildBottomBar() {
    final selected = _selectedTicket;
    if (selected == null) return const SizedBox.shrink();
    final name = selected["name"]?.toString() ?? '';
    final qty = _totalQuantity;
    final total = _totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF120104).withOpacity(0.92),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$qty ${qty > 1 ? "billets" : "billet"} · $name',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.72),
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '${total.toStringAsFixed(0)},00 MAD',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _showCinInputDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.continueText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MODAL CIN / NOM — dark Wydad
  // ═══════════════════════════════════════════════════════════
  void _showCinInputDialog() {
    final l10n = AppLocalizations.of(context)!;
    _cinController.clear();
    _fullNameController.clear();
    setState(() {
      _isCinValid = false;
      _isFullNameValid = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isCinValid = RegExp(r'^[A-Z][A-Za-z0-9]{0,7}$')
                .hasMatch(_cinController.text);
            bool isFullNameValid = _fullNameController.text.length >= 4 &&
                RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$')
                    .hasMatch(_fullNameController.text) &&
                _fullNameController.text.split(' ').length >= 2;
            bool allFieldsValid = isCinValid && isFullNameValid;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8B10E)
                                .withOpacity(0.14),
                            border: Border.all(
                              color: const Color(0xFFE8B10E)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFF5CD52),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.personalInformation,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.enterPersonalInfoToFinalizeOrder,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  height: 1.4,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Nom complet
                    _darkField(
                      label: l10n.fullNameRequired,
                      hint: l10n.fullNameHint,
                      controller: _fullNameController,
                      icon: Icons.person_outline,
                      onChanged: (_) => setDialogState(() {
                        _validateFullName();
                      }),
                      errorText:
                      _fullNameController.text.isNotEmpty &&
                          !isFullNameValid
                          ? l10n.fullNameInvalid
                          : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZÀ-ÿ\s\-]')),
                        LengthLimitingTextInputFormatter(100),
                      ],
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),

                    // CIN
                    _darkField(
                      label: l10n.cinRequired,
                      hint: l10n.cinHint,
                      controller: _cinController,
                      icon: Icons.badge_outlined,
                      onChanged: (_) => setDialogState(() {
                        _validateCin();
                      }),
                      errorText:
                      _cinController.text.isNotEmpty && !isCinValid
                          ? l10n.cinInvalid
                          : null,
                      inputFormatters: [
                        CinTextFormatter(),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white.withOpacity(0.08),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.18)),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.cancel,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: allFieldsValid
                                ? () {
                              Navigator.of(context).pop();
                              _createOrder();
                            }
                                : null,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: allFieldsValid
                                      ? [
                                    const Color(0xFFD11A2A),
                                    const Color(0xFFA8161F)
                                  ]
                                      : [
                                    Colors.grey.withOpacity(0.3),
                                    Colors.grey.withOpacity(0.3)
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.continueText,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _darkField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
            prefixIcon:
            Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            errorText: errorText,
            errorStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color(0xFFE5484D),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5484D)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFE5484D), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedTickets =
    ticketQuantities.entries.where((e) => e.value > 0).toList();
    if (selectedTickets.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final firstTicket = selectedTickets.first;
      final fullNameParts = _fullNameController.text.trim().split(' ');
      final firstName = fullNameParts.isNotEmpty ? fullNameParts.first : '';
      final name =
      fullNameParts.length > 1 ? fullNameParts.sublist(1).join(' ') : '';

      final response = await http.post(
        Uri.parse("https://ticketing.ma/api/customer/orders"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
        body: {
          "event_id": widget.eventId.toString(),
          "ticket_id": firstTicket.key.toString(),
          "quantity": firstTicket.value.toString(),
          "payment_type": "CMI",
          "cin": _cinController.text,
          "name": name,
          "first_name": firstName,
        },
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final orderData = data["data"];
          if (orderData is Map<String, dynamic> &&
              orderData.containsKey("order_number")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CMIPaymentWebViewTicket(
                  amount: _totalPrice,
                  orderData: {
                    "token": widget.token,
                    "order": orderData,
                    "order_number": orderData["order_number"],
                    "eventId": widget.eventId,
                    "organizationId": widget.currentOrganizationId,
                    "name": name,
                    "first_name": firstName,
                  },
                  selectedTickets: selectedTickets,
                ),
              ),
            );
          } else {
            _showErrorDialog(l10n.orderNumberMissing);
          }
        } else {
          _showErrorDialog(data['message'] ?? l10n.orderCreationFailed);
        }
      } else {
        _showErrorDialog(l10n.orderCreationError);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog("${l10n.connectionError}: $e");
    }
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => Dialog(
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5484D).withOpacity(0.14),
                  border: Border.all(
                      color: const Color(0xFFE5484D).withOpacity(0.3)),
                ),
                child: const Icon(Icons.error_outline,
                    color: Color(0xFFE5484D), size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.error,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
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
                        l10n.ok,
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
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CinTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();

    String result = '';
    bool hasFirstLetter = false;

    for (String char in text.split('')) {
      if (!hasFirstLetter && RegExp(r'[A-Z]').hasMatch(char)) {
        result += char;
        hasFirstLetter = true;
      } else if (hasFirstLetter &&
          RegExp(r'[A-Z0-9]').hasMatch(char) &&
          result.length < 8) {
        result += char;
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}