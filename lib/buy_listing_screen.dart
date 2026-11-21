import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'cmi_payment_ticket.dart';          // ✅ relatif
import 'wallet_service.dart';             // ✅ relatif
import 'ticketplace_service.dart';
import 'l10n/app_localizations.dart';

class BuyListingScreen extends StatefulWidget {
  final String token;
  final int listingId;
  final String? currentOrganizationId;

  const BuyListingScreen({
    Key? key,
    required this.token,
    required this.listingId,
    this.currentOrganizationId,
  }) : super(key: key);

  @override
  State<BuyListingScreen> createState() => _BuyListingScreenState();
}

class _BuyListingScreenState extends State<BuyListingScreen> {
  Map<String, dynamic>? _listing;
  bool _loading = true;
  bool _isProcessing = false;

  final Color primary = const Color(0xFFA8161F);

  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _walletPinController = TextEditingController();

  bool _isCinValid = false;
  bool _isFullNameValid = false;

  double _walletBalance = 0.0;
  bool _isWalletLoading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
    _fetchWalletBalance();
    _cinController.addListener(_validateCin);
    _fullNameController.addListener(_validateFullName);
  }

  @override
  void dispose() {
    _cinController.dispose();
    _fullNameController.dispose();
    _walletPinController.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final info = await WalletService.getWalletInfo(widget.token);
      if (mounted) {
        setState(() {
          _walletBalance = (info?['balance'] as num?)?.toDouble() ?? 0.0;
          _isWalletLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isWalletLoading = false);
    }
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

  Future<void> _load() async {
    final l = await TicketplaceService.getListingDetail(
      token: widget.token,
      listingId: widget.listingId,
    );
    if (mounted) {
      setState(() {
        _listing = l;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF170205),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }
    if (_listing == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF170205),
        body: Center(
          child: Text('Annonce introuvable', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final price = _listing!['resale_price'] ?? 0;
    final fee = _listing!['buyer_fee'] ?? 0;
    final total = _listing!['total_buyer_amount'] ?? 0;
    final count = _listing!['tickets_count'] ?? 1;
    final subtotal = (price is int) ? price * count : (price as double) * count;

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
                colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
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
          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SizedBox(
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
                          "Revente officielle",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                ),

                // --- CONTENU ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      // 1. CARTE BILLET
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFA8161F),
                              Color(0xFF7A0D17),
                              Color(0xFF4A0710)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0x2EFFFFFF)),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x80000000),
                                blurRadius: 40,
                                offset: Offset(0, 20)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -80,
                              top: -110,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0x1AFFFFFF),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BILLET EN REVENTE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.4,
                                      color: Color(0xC7FFFFFF)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _listing!['ticket_name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _meta('Catégorie', _listing!['ticket_name'] ?? ''),
                                    _meta('Billets', '$count'),
                                    _meta('Zone', _listing!['zone'] ?? ''),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user,
                                        size: 14, color: Color(0xDBFFFFFF)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Vendu par ${_listing!['seller_name'] ?? ''} · compte vérifié',
                                        style: const TextStyle(
                                            fontSize: 12, color: Color(0xDBFFFFFF)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. MONTANT
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: Column(
                          children: [
                            _row('Prix par billet', '$price MAD'),
                            _row('Quantité', '× $count'),
                            _row('Sous-total', '$subtotal MAD'),
                            _row('Frais de service', '$fee MAD'),
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              color: const Color(0x1AFFFFFF),
                            ),
                            _row('Total à payer', '$total MAD',
                                bold: true, big: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. GARANTIES
                      Column(
                        children: [
                          _buildGuarantee(
                              "Le billet du vendeur est annulé et un nouveau QR code est émis à votre nom."),
                          const SizedBox(height: 10),
                          _buildGuarantee(
                              "Vos billets apparaissent tout de suite dans « Mes billets »."),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 4. MÉTHODE DE PAIEMENT (info visuelle)
                      const Text(
                        "Payer avec",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xDBFFFFFF)),
                      ),
                      const SizedBox(height: 10),
                      _payOptionInfo('BAAS_WALLET', 'Wydad Pay',
                          'Solde disponible · instantané',
                          isWallet: true),
                      const SizedBox(height: 8),
                      _payOptionInfo('BAAS_CARD', 'Carte bancaire',
                          'Visa, Mastercard · 3D Secure'),

                      const SizedBox(height: 16),

                      // 5. BOUTON PAYER (ouvre la popup)
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _showCinInputDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFA8161F)))
                              : Text(
                            'Payer $total MAD',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xB8FFFFFF))),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    ),
  );

  Widget _row(String l, String v, {bool bold = false, bool big = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: const TextStyle(color: Color(0xB8FFFFFF), fontSize: 14)),
            Text(
              v,
              style: TextStyle(
                color: Colors.white,
                fontSize: big ? 22 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  Widget _buildGuarantee(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.check, size: 16, color: Color(0xFFF5CD52)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 13, color: Color(0xC7FFFFFF), height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _payOptionInfo(String value, String title, String subtitle,
      {bool isWallet = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isWallet ? Colors.transparent : const Color(0x1FFFFFFF),
            ),
            child: Icon(
              isWallet ? Icons.account_balance_wallet : Icons.credit_card,
              color: Colors.white,
              size: isWallet ? 30 : 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isWallet
                        ? const Color(0xFFF5CD52)
                        : const Color(0xA6FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // OVERLAY PROCESSING
  // ═══════════════════════════════════════════════════════════
  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withOpacity(0.65),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                      offset: Offset(0, 20)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFF5CD52)),
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.processingTitle,
                    style: const TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.processingSubtitle,
                    style: TextStyle(
                        fontFamily: 'urbanist',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOG CIN / NOM / PAIEMENT
  // ═══════════════════════════════════════════════════════════
  void _showCinInputDialog() {
    _cinController.clear();
    _fullNameController.clear();
    _walletPinController.clear();
    setState(() {
      _isCinValid = false;
      _isFullNameValid = false;
    });

    String paymentMethod = 'CMI';
    bool hasEnoughWallet = false;

    final safeBottom = MediaQuery.of(context).padding.bottom;

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
            bool pinValid = _walletPinController.text.length == 4;

            hasEnoughWallet = _walletBalance >=
                ((_listing!['total_buyer_amount'] ?? 0) as num).toDouble();
            bool canPay = allFieldsValid &&
                (paymentMethod == 'CMI' ||
                    (paymentMethod == 'WALLET' &&
                        hasEnoughWallet &&
                        pinValid));

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 40 + safeBottom),
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
                          offset: Offset(0, 20)),
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
                              color: const Color(0xFFE8B10E).withOpacity(0.14),
                              border: Border.all(
                                  color:
                                  const Color(0xFFE8B10E).withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.person_outline,
                                color: Color(0xFFF5CD52), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.personalInformation,
                                    style: const TextStyle(
                                        fontFamily: 'urbanist',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(l10n.enterPersonalInfoToFinalizeOrder,
                                    style: TextStyle(
                                        fontFamily: 'urbanist',
                                        fontSize: 12,
                                        height: 1.4,
                                        color: Colors.white.withOpacity(0.7))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _darkField(
                        label: l10n.fullNameRequired,
                        hint: l10n.fullNameHint,
                        controller: _fullNameController,
                        icon: Icons.person_outline,
                        onChanged: (_) =>
                            setDialogState(() => _validateFullName()),
                        errorText: _fullNameController.text.isNotEmpty &&
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
                      _darkField(
                        label: l10n.cinRequired,
                        hint: l10n.cinHint,
                        controller: _cinController,
                        icon: Icons.badge_outlined,
                        onChanged: (_) => setDialogState(() => _validateCin()),
                        errorText:
                        _cinController.text.isNotEmpty && !isCinValid
                            ? l10n.cinInvalid
                            : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          LengthLimitingTextInputFormatter(8),
                        ],
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      Text(l10n.paymentMethodLabel,
                          style: const TextStyle(
                              fontFamily: 'urbanist',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 10),

                      // Wallet
                      GestureDetector(
                        onTap: hasEnoughWallet
                            ? () => setDialogState(
                                () => paymentMethod = 'WALLET')
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: paymentMethod == 'WALLET'
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: paymentMethod == 'WALLET'
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: hasEnoughWallet
                                      ? const Color(0xFFF5CD52)
                                      : Colors.grey,
                                  size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.wydadPayLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'urbanist',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text(
                                      hasEnoughWallet
                                          ? '${l10n.balanceLabel}: ${_walletBalance.toStringAsFixed(2)} MAD'
                                          : l10n.insufficientBalance,
                                      style: TextStyle(
                                          color: hasEnoughWallet
                                              ? Colors.white54
                                              : Colors.redAccent,
                                          fontFamily: 'urbanist',
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              if (paymentMethod == 'WALLET')
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF5CD52), size: 18),
                            ],
                          ),
                        ),
                      ),

                      // PIN
                      if (paymentMethod == 'WALLET') ...[
                        const SizedBox(height: 10),
                        _darkField(
                          label: l10n.pinCodeLabel,
                          hint: l10n.pinCodeHint,
                          controller: _walletPinController,
                          icon: Icons.lock_outline,
                          obscureText: true,
                          onChanged: (_) => setDialogState(() {}),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // CMI
                      GestureDetector(
                        onTap: () =>
                            setDialogState(() => paymentMethod = 'CMI'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: paymentMethod == 'CMI'
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: paymentMethod == 'CMI'
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.credit_card,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.cardBankLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'urbanist',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text(l10n.payByCard,
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontFamily: 'urbanist',
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              if (paymentMethod == 'CMI')
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF5CD52), size: 18),
                            ],
                          ),
                        ),
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
                                  child: Text(l10n.cancel,
                                      style: TextStyle(
                                          fontFamily: 'urbanist',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9))),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: canPay
                                  ? () {
                                Navigator.of(context).pop();
                                _processCheckout(
                                  paymentMethod,
                                  pin: paymentMethod == 'WALLET'
                                      ? _walletPinController.text
                                      : null,
                                  customerName:
                                  _fullNameController.text,
                                  customerCin: _cinController.text,
                                );
                              }
                                  : null,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(colors: canPay
                                      ? [
                                    const Color(0xFFD11A2A),
                                    const Color(0xFFA8161F)
                                  ]
                                      : [
                                    Colors.grey.withOpacity(0.3),
                                    Colors.grey.withOpacity(0.3)
                                  ]),
                                ),
                                child: Center(
                                  child: Text(
                                    '${l10n.pay} ${((_listing!['total_buyer_amount'] ?? 0) as num).toDouble().toStringAsFixed(0)} MAD',
                                    style: const TextStyle(
                                        fontFamily: 'urbanist',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
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
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'urbanist',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.72))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          keyboardType: obscureText ? TextInputType.number : TextInputType.text,
          cursorColor: Colors.white,
          style: const TextStyle(
              fontFamily: 'urbanist', fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'urbanist',
                fontSize: 13,
                color: Colors.white.withOpacity(0.4)),
            prefixIcon:
            Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            errorText: errorText,
            errorStyle: const TextStyle(
                fontFamily: 'urbanist',
                fontSize: 11,
                color: Color(0xFFE5484D)),
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
              borderSide: const BorderSide(color: Color(0xFFE5484D), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // APPEL API CHECKOUT (BAAS_WALLET ou BAAS_CARD)
  // ═══════════════════════════════════════════════════════════
  Future<void> _processCheckout(
      String method, {
        String? pin,
        required String customerName,
        required String customerCin,
      }) async {
    if (method == 'WALLET' && (pin == null || pin.length != 4)) {
      _showErrorDialog(l10n.pinRequired);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await TicketplaceService.checkoutListing(
        token: widget.token,
        listingId: widget.listingId,
        paymentType: method == 'WALLET' ? 'BAAS_WALLET' : 'BAAS_CARD',
        customerName: customerName,
        customerCin: customerCin,
        pin: pin,
      );

      if (response == null) {
        _showErrorDialog(l10n.genericErrorMsg);
        return;
      }

      if (response['success'] != true) {
        _showErrorDialog(response['message'] ?? l10n.genericErrorMsg);
        return;
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        _showErrorDialog(l10n.genericErrorMsg);
        return;
      }

      if (method == 'WALLET') {
        final isPaid = data['is_paid'] == true ||
            (data['payment_status'] as num?)?.toInt() == 1;
        if (!isPaid) {
          _showErrorDialog(l10n.genericErrorMsg);
          return;
        }
        await _fetchWalletBalance();
        _showSuccessDialog();
      } else {
        final orderId = data['order_id'];
        if (orderId == null) {
          _showErrorDialog(
              'Erreur : Impossible de créer la commande pour le paiement CB.');
          return;
        }

        final orderNumber = data['order_number']?.toString() ?? '';
        final amount = (_listing!['total_buyer_amount'] ?? 0).toDouble();

        setState(() => _isProcessing = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CMIPaymentWebViewTicket(
              amount: amount,
              orderData: {
                "token": widget.token,
                "order": data,
                "order_number": orderNumber,
                "eventId": _listing!['event_id'],
                "organizationId": widget.currentOrganizationId,
              },
              selectedTickets: const [],
            ),
          ),
        );
        return;
      }
    } catch (e) {
      _showErrorDialog('Une erreur est survenue: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOG SUCCÈS
  // ═══════════════════════════════════════════════════════════
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  color: const Color(0xFFF5CD52).withOpacity(0.14),
                  border: Border.all(
                      color: const Color(0xFFF5CD52).withOpacity(0.3)),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Color(0xFFF5CD52), size: 34),
              ),
              const SizedBox(height: 20),
              Text(l10n.paymentSuccessTitle,
                  style: const TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                l10n.paymentSuccessMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // ferme le dialog
                    Navigator.pop(context); // quitte l'écran
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)]),
                    ),
                    child: Center(
                      child: Text(l10n.backToEvents,
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
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOG ERREUR
  // ═══════════════════════════════════════════════════════════
  void _showErrorDialog(String message) {
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
              Text(l10n.error,
                  style: const TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75)),
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
                          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)]),
                    ),
                    child: Center(
                      child: Text(l10n.ok,
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
        ),
      ),
    );
  }
}