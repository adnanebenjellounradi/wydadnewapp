import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'wallet_service.dart';

class WalletWithdrawCashPage extends StatefulWidget {
  final String token;

  const WalletWithdrawCashPage({Key? key, required this.token})
      : super(key: key);

  @override
  State<WalletWithdrawCashPage> createState() =>
      _WalletWithdrawCashPageState();
}

class _WalletWithdrawCashPageState extends State<WalletWithdrawCashPage> {
  final Color primary = const Color(0xFFA8161F);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  int _step = 0;
  bool _isLoading = true;
  double _balance = 0;
  bool _isSubmitting = false;

  final TextEditingController _amountCtrl =
  TextEditingController(text: '300');
  final TextEditingController _pinCtrl = TextEditingController();

  String _amount = '300';
  String? _withdrawCode;

  @override
  void initState() {
    super.initState();

    _amountCtrl.addListener(() {
      setState(() {
        _amount = _amountCtrl.text;
      });
    });

    _loadBalance();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);

    final wallet = await WalletService.getWalletInfo(widget.token);

    if (!mounted) return;

    setState(() {
      _balance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
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

  Future<void> _submit() async {
    final pin = _pinCtrl.text;

    if (pin.length < 4) {
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

    try {
      final res = await WalletService.cashoutAgency(
        token: widget.token,
        amount: _amountValue,
        pin: pin,
        description: l10n.walletWithdrawCashDescription,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      print("🔍 [WITHDRAW CASH] Réponse API = $res");

      if (res != null && res['success'] == true) {
        final data = res['data'];

        final code = data?['withdrawal_code']?.toString() ??
            data?['code']?.toString() ??
            data?['reference']?.toString() ??
            '------';

        setState(() {
          _withdrawCode = code;
          _step = 1;
        });
      } else {
        _showError(
          res?['message']?.toString() ??
              l10n.walletWithdrawFailed,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      print("🔍 [WITHDRAW CASH] Erreur = $e");

      _showError(l10n.walletWithdrawConnectionError);
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: _step == 0
                      ? _buildFormStep()
                      : _buildCodeStep(),
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
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            l10n.walletWithdrawCashTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ─── STEP 0 : FORMULAIRE ───

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.walletWithdrawAmountToWithdraw,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
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
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
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
        ),
        const SizedBox(height: 10),
        Row(
          children: [100, 200, 300, 500].map((v) {
            final on = _amount == v.toString();

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: v == 500 ? 0 : 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _amountCtrl.text = v.toString();
                      _amount = v.toString();
                    });
                  },
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: on
                          ? Colors.white.withOpacity(0.18)
                          : Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: on
                            ? Colors.white.withOpacity(0.45)
                            : Colors.white.withOpacity(0.14),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$v',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.storefront_outlined,
              color: Colors.white.withOpacity(0.6),
              size: 14,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.walletWithdrawAgencyInstructions,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.78),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.walletWithdrawEnterPin,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.86),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: '••••',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              letterSpacing: 12,
              color: Colors.white.withOpacity(0.35),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 50,
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
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            )
                : Text(
              l10n.walletWithdrawGetCode,
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

  // ─── STEP 1 : CODE ───

  Widget _buildCodeStep() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.walletWithdrawCodeInstructions,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            height: 1.5,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                l10n.walletWithdrawCodeLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xFF07060F).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _withdrawCode ?? '------',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                  color: Color(0xFFA8161F),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: Colors.black.withOpacity(0.10),
              ),
              const SizedBox(height: 10),
              _kvWhite(
                l10n.walletWithdrawAmountLabel,
                '$_amount,00 MAD',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFFFC97A).withOpacity(0.10),
            border: Border.all(
              color: const Color(0xFFFFC97A).withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFFFC97A),
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.walletWithdrawBlockedAmountInfo,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.86),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  '/acceuil',
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
              l10n.walletWithdrawBackToHome,
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

  Widget _kvWhite(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: const Color(0xFF07060F).withOpacity(0.6),
          ),
        ),
        Text(
          v,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFA8161F),
          ),
        ),
      ],
    );
  }
}