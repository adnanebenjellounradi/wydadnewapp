import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletRechargeRibPage extends StatefulWidget {
  final String token;
  const WalletRechargeRibPage({Key? key, required this.token})
      : super(key: key);

  @override
  State<WalletRechargeRibPage> createState() => _WalletRechargeRibPageState();
}

class _WalletRechargeRibPageState extends State<WalletRechargeRibPage> {
  final Color primary = const Color(0xFFA8161F);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _isLoading = true;
  String _walletRib = '';
  String _holder = '';
  String _bank = '';
  String _walletPhone = '';
  bool _copied = false;

  // Bénéficiaires (comptes bancaires liés par l'utilisateur)
  List<Map<String, dynamic>> _beneficiaries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final w = await WalletService.getWalletInfo(widget.token);
    final b = await WalletService.getBeneficiaries(widget.token);

    if (!mounted) return;
    setState(() {
      _walletRib = w?['rib']?.toString() ?? '';
      _holder = w?['full_name']?.toString() ?? '';
      _bank = w?['bank_name']?.toString() ?? '';
      _walletPhone = w?['phone']?.toString() ?? '';
      _beneficiaries = b;
      _isLoading = false;
    });
  }

  Future<void> _copyRib() async {
    if (_walletRib.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _walletRib.replaceAll(' ', '')));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.ribCopied, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  // ─── Ajout d'un compte bancaire (bénéficiaire) ───
  Future<void> _showAddBankAccountSheet() async {
    final nameCtrl = TextEditingController();
    final ribCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: _walletPhone);
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF23030A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
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
                  const SizedBox(height: 16),
                  Text(
                    l10n.addBankAccount,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addBankAccountDescription,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sheetField(
                    label: l10n.accountName,
                    hint: l10n.accountNameHint,
                    controller: nameCtrl,
                  ),
                  const SizedBox(height: 12),
                  _sheetField(
                    label: l10n.ribWithLength('24'),
                    hint: l10n.ribHint,
                    controller: ribCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sheetField(
                    label: l10n.associatedPhoneNumber,
                    hint: l10n.phoneNumberHint,
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        final name = nameCtrl.text.trim();
                        final rib = ribCtrl.text.replaceAll(' ', '');
                        final phone = phoneCtrl.text.trim();

                        if (name.isEmpty) {
                          _sheetError(ctx, l10n.accountNameRequired);
                          return;
                        }
                        if (rib.length != 24) {
                          _sheetError(
                              ctx, l10n.ribMustContain24Digits);
                          return;
                        }
                        if (phone.length < 9) {
                          _sheetError(
                              ctx, l10n.phoneNumberRequired);
                          return;
                        }

                        setSheetState(() => isSubmitting = true);

                        final res = await WalletService.addBeneficiary(
                          token: widget.token,
                          name: name,
                          rib: rib,
                          recipientPhone: phone.startsWith('+')
                              ? phone
                              : '+212$phone',
                        );

                        if (!ctx.mounted) return;
                        setSheetState(() => isSubmitting = false);

                        if (res != null && res['success'] == true) {
                          Navigator.pop(ctx, true);
                        } else {
                          _sheetError(
                            ctx,
                            res?['message']?.toString() ??
                                l10n.addFailed,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation(primary),
                        ),
                      )
                          : Text(
                        l10n.saveBankAccount,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((added) {
      if (added == true) {
        _load(); // recharge tout (RIB + bénéficiaires)
      }
    });
  }

  void _sheetError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _sheetField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          ),
        ),
      ],
    );
  }

  // ─── Suppression d'un bénéficiaire ───
  Future<void> _deleteBeneficiary(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF23030A),
        title: Text(
          l10n.deleteAccountConfirmationTitle,
          style: TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        content: Text(
          l10n.deleteAccountConfirmationMessage(name),
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFD11A2A),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await WalletService.deleteBeneficiary(
      token: widget.token,
      id: id,
    );
    if (!mounted) return;
    if (res != null && res['success'] == true) {
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res?['message']?.toString() ?? l10n.deleteFailed,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ));
    }
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
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primary))
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bankTransferDescription,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildMainRibSection(),
                      const SizedBox(height: 22),
                      _buildBeneficiariesSection(),
                      const SizedBox(height: 22),
                      _buildInfoList(),
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
          Text(
            l10n.bankTransferTitle,
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

  // ─── SECTION 1 : RIB wallet (pour RECEVOIR) ───
  Widget _buildMainRibSection() {
    if (_walletRib.isNotEmpty) {
      // Cas 1 : RIB disponible → afficher la carte + copier
      return Column(
        children: [
          _buildRibCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _button(
                  label: _copied ? l10n.ribCopied : l10n.copyRib,
                  icon: Icons.copy,
                  primaryStyle: true,
                  onTap: _copyRib,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _button(
                  label: l10n.share,
                  icon: Icons.ios_share,
                  primaryStyle: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        l10n.shareComingSoon,
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: primary,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Cas 2 : PAS de RIB → formulaire pour en créer un
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD11A2A),
                      Color(0xFFA8161F),
                      Color(0xFF6E0B12)
                    ],
                  ),
                ),
                child: const Icon(Icons.account_balance,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.noBankAccount,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noBankAccountDescription,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _showAddBankAccountSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.addBankAccount,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION 2 : bénéficiaires (comptes liés) ───
  Widget _buildBeneficiariesSection() {
    if (_beneficiaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myBankAccounts,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: _showAddBankAccountSheet,
              child: Text(
                l10n.add,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._beneficiaries.map((b) {
          final id = b['id'] as int?;
          final name = b['name']?.toString() ?? l10n.defaultAccountName;
          final rib = b['rib']?.toString().replaceAll(' ', '') ?? '';
          final masked = rib.length >= 4
              ? '•••• ${rib.substring(rib.length - 4)}'
              : '••••';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              constraints: const BoxConstraints(minHeight: 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.10),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.ribMaskedFormat(masked),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (id != null)
                    GestureDetector(
                      onTap: () => _deleteBeneficiary(id, name),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: Icon(Icons.delete_outline,
                            color: Colors.white.withOpacity(0.7), size: 16),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Carte RIB wallet ───
  Widget _buildRibCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myWalletRib,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _walletRib,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountHolder,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    Text(
                      _holder.isNotEmpty ? _holder : l10n.defaultAccountHolder,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bank,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    Text(
                      _bank.isNotEmpty ? _bank : l10n.defaultBank,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    required IconData icon,
    required bool primaryStyle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryStyle ? Colors.white : Colors.white.withOpacity(0.08),
          border: primaryStyle
              ? null
              : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: primaryStyle ? primary : Colors.white, size: 17),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primaryStyle ? primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoList() {
    final items = [
      l10n.transferInfo1,
      l10n.transferInfo2,
      l10n.transferInfo3,
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: items.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.white.withOpacity(0.6), size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
