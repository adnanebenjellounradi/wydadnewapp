import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'wallet_service.dart';
import 'wallet_add_beneficiary_page.dart';

class WalletWithdrawBankPage extends StatefulWidget {
  final String token;

  const WalletWithdrawBankPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<WalletWithdrawBankPage> createState() =>
      _WalletWithdrawBankPageState();
}

class _WalletWithdrawBankPageState extends State<WalletWithdrawBankPage> {
  final Color primary = const Color(0xFFA8161F);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  int _step = 0;
  bool _isLoading = true;
  double _balance = 0;

  String _walletPhone = '';
  String _walletFullName = '';
  String _walletRib = '';

  List<Map<String, dynamic>> _accounts = [];
  int _selectedAccountIndex = 0;

  String _amount = '500';
  String _pin = '';
  bool _isSubmitting = false;

  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final wallet = await WalletService.getWalletInfo(widget.token);
    final beneficiaries =
    await WalletService.getBeneficiaries(widget.token);

    if (!mounted) return;

    _walletPhone = wallet?['phone']?.toString() ?? '';
    _walletFullName = wallet?['full_name']?.toString() ?? '';
    _walletRib = wallet?['rib']?.toString() ?? '';

    final accounts = <Map<String, dynamic>>[];

    // 1) Compte principal du wallet
    if (_walletRib.isNotEmpty) {
      accounts.add({
        'id': null,
        'name': l10n.walletWithdrawMyWydadPayAccount,
        'bank_name': 'Wydad Pay',
        'rib': _walletRib,
        'beneficiary_name': _walletFullName,
        'is_default': true,
        'is_wallet': true,
      });
    }

    // 2) Bénéficiaires ajoutés
    for (final b in beneficiaries) {
      accounts.add({
        'id': b['id'],
        'name': b['name']?.toString() ??
            l10n.walletWithdrawBankAccount,
        'bank_name': b['bank_name']?.toString() ?? '',
        'rib': b['rib']?.toString() ?? '',
        'beneficiary_name': b['name']?.toString() ?? '',
        'is_default': false,
        'is_wallet': false,
      });
    }

    setState(() {
      _balance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
      _accounts = accounts;
      _selectedAccountIndex = 0;
      _isLoading = false;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, dynamic>? get _selectedAccount {
    if (_accounts.isEmpty) return null;

    if (_selectedAccountIndex >= _accounts.length) {
      return _accounts.first;
    }

    return _accounts[_selectedAccountIndex];
  }

  Future<void> _submit() async {
    final account = _selectedAccount;

    if (account == null) {
      _showError(l10n.walletWithdrawNoBankAccount);
      return;
    }

    if (_pin.length < 4) {
      _showError(l10n.walletWithdrawPinFourDigits);
      return;
    }

    if (_amountValue < 50) {
      _showError(l10n.walletWithdrawMinimumAmount);
      return;
    }

    if (_amountValue > _balance) {
      _showError(l10n.walletWithdrawInsufficientBalance);
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await WalletService.cashout(
      token: widget.token,
      amount: _amountValue,
      rib: account['rib']?.toString().replaceAll(' ', '') ?? '',
      beneficiaryName:
      account['beneficiary_name']?.toString() ?? '',
      pin: _pin,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (res != null && res['success'] == true) {
      setState(() => _step = 1);
    } else {
      _showError(
        res?['message']?.toString() ??
            l10n.walletWithdrawTransferFailed,
      );
    }
  }

  Future<void> _onAddAccount() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletAddBeneficiaryPage(
          token: widget.token,
          defaultPhone: _walletPhone,
        ),
      ),
    );

    if (added == true) {
      _loadData();
    }
  }

  Future<void> _onDeleteAccount(
      Map<String, dynamic> acc,
      ) async {
    final id = acc['id'];

    // Le compte principal du wallet ne peut pas être supprimé.
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF23030A),
        title: Text(
          l10n.walletWithdrawDeleteAccountTitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
          ),
        ),
        content: Text(
          l10n.walletWithdrawDeleteAccountMessage(
            acc['name']?.toString() ?? '',
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.walletWithdrawCancel,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.walletWithdrawDelete,
              style: const TextStyle(
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
      id: id as int,
    );

    if (!mounted) return;

    if (res != null && res['success'] == true) {
      _loadData();
    } else {
      _showError(
        res?['message']?.toString() ??
            l10n.walletWithdrawDeleteFailed,
      );
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
            colors: [
              Color(0xFF4A0710),
              Color(0xFF23030A),
              Color(0xFF120104),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(color: primary),
          )
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, 12, 16, 0,
                ),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 20,
                  ),
                  child: _step == 0
                      ? _buildFormStep()
                      : _buildSuccessStep(),
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            l10n.walletWithdrawBankTitle,
            style: const TextStyle(
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

  // ─── STEP 0 : FORMULAIRE ───

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.walletWithdrawDestinationAccount,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        if (_accounts.isEmpty)
          _emptyAccountCard()
        else
          ..._accounts.asMap().entries.map((entry) {
            final i = entry.key;
            final acc = entry.value;
            final selected = i == _selectedAccountIndex;

            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: _accountCard(
                acc,
                selected: selected,
                index: i,
              ),
            );
          }),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: _onAddAccount,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.26),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              l10n.walletWithdrawAddAnotherAccount,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.walletWithdrawAmount,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              l10n.walletWithdrawBalance(
                _balance.toStringAsFixed(2).replaceAll('.', ','),
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  controller: TextEditingController(text: _amount)
                    ..selection = TextSelection.collapsed(
                      offset: _amount.length,
                    ),
                  onChanged: (v) => setState(() => _amount = v),
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              Text(
                'MAD',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          l10n.walletWithdrawEstimatedReception,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            l10n.walletWithdrawEnterPin,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (v) => setState(() => _pin = v),
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 18,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: '••••',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              letterSpacing: 18,
              color: Colors.white.withOpacity(0.35),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            )
                : Text(
              l10n.walletWithdrawButton(_amount),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── CARTE COMPTE BANCAIRE ───

  Widget _accountCard(
      Map<String, dynamic> acc, {
        required bool selected,
        required int index,
      }) {
    final bank = acc['bank_name']?.toString() ?? '';
    final name = acc['name']?.toString() ?? '[BANQUE]';
    final isDefault = acc['is_default'] == true;
    final isWallet = acc['is_wallet'] == true;

    final rib = acc['rib']?.toString().replaceAll(' ', '') ?? '';

    final maskedRib = rib.length >= 2
        ? '•••• •••• ${rib.substring(rib.length - 2)}'
        : '•••• •••• [XX]';

    return GestureDetector(
      onTap: () => setState(() => _selectedAccountIndex = index),
      onLongPress: isWallet ? null : () => _onDeleteAccount(acc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        constraints: const BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.14),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB0141F),
                    Color(0xFF860D16),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Icon(
                isWallet
                    ? Icons.account_balance_wallet
                    : Icons.account_balance,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.isNotEmpty
                        ? '$bank · ${l10n.walletWithdrawInMyName}'
                        : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    l10n.walletWithdrawRib(maskedRib),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),

                  if (bank.isNotEmpty && !isWallet)
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),

            if (isDefault)
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFF5CD52).withOpacity(0.14),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.walletWithdrawDefault,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF5CD52),
                  ),
                ),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Colors.white : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Icon(
                  Icons.check,
                  color: primary,
                  size: 12,
                )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  // ─── AUCUN COMPTE ───

  Widget _emptyAccountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.6),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.walletWithdrawEmptyAccounts,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1 : SUCCÈS ───

  Widget _buildSuccessStep() {
    final account = _selectedAccount;
    final name = account?['name']?.toString() ??
        l10n.walletWithdrawBankAccount;

    return Column(
      children: [
        const SizedBox(height: 40),

        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5CD52).withOpacity(0.14),
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFFF5CD52),
            size: 32,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          l10n.walletWithdrawTransferSent,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$_amount,00',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'MAD',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.72),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          l10n.walletWithdrawToAccount(name),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withOpacity(0.72),
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: Column(
            children: [
              _kv(
                l10n.walletWithdrawStatus,
                l10n.walletWithdrawProcessing,
              ),
              const SizedBox(height: 8),
              _kv(
                l10n.walletWithdrawDate,
                DateTime.now().toString().substring(0, 16),
              ),
              const SizedBox(height: 8),
              _kv(
                l10n.walletWithdrawEstimatedReceptionLabel,
                l10n.walletWithdrawEstimatedReceptionValue,
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/wallet',
                  (r) => false,
              arguments: {'token': widget.token},
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.walletWithdrawBackToWallet,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── LIGNE CLÉ / VALEUR ───

  Widget _kv(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}