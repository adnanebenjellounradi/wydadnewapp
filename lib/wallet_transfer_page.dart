import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'wallet_service.dart';

class WalletTransferPage extends StatefulWidget {
  final String token;

  const WalletTransferPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<WalletTransferPage> createState() => _WalletTransferPageState();
}

class _WalletTransferPageState extends State<WalletTransferPage> {
  int _step = 0;
  String _recipient = '';
  String _amount = '100';
  String _note = '';
  String _pin = '';
  bool _isLoading = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final Color primary = const Color(0xFFA8161F);

  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

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

  void _goNext() async {
    if (_step == 0) {
      final cleaned = _phoneCtrl.text.replaceAll(' ', '');

      if (!RegExp(r'^[6-7][0-9]{8}$').hasMatch(cleaned)) {
        _showError(l10n.walletTransferInvalidPhone);
        return;
      }

      setState(() {
        _recipient = '+212$cleaned';
        _step = 1;
      });
    } else if (_step == 1) {
      if (_amountValue < 10) {
        _showError(l10n.walletTransferMinimumAmount);
        return;
      }

      setState(() {
        _note = _noteCtrl.text;
        _step = 2;
      });
    } else if (_step == 2) {
      if (_pin.length < 4) {
        _showError(l10n.walletTransferPinFourDigits);
        return;
      }

      setState(() => _isLoading = true);

      final res = await WalletService.transfer(
        token: widget.token,
        recipientPhone: _recipient,
        amount: _amountValue,
        pin: _pin,
        note: _note,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (res != null && res['success'] == true) {
        setState(() => _step = 3);
      } else {
        _showError(
          res?['message']?.toString() ?? l10n.walletTransferFailed,
        );
      }
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: _step == 0
                      ? _buildRecipientStep()
                      : _step == 1
                      ? _buildAmountStep()
                      : _step == 2
                      ? _buildPinStep()
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
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_step > 0 && _step < 3) {
                setState(() => _step--);
              } else {
                Navigator.maybePop(context);
              }
            },
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
            _step == 3
                ? l10n.walletTransferSuccess
                : l10n.walletTransferTitle,
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

  // ─── STEP 0 : DESTINATAIRE ───

  Widget _buildRecipientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.walletTransferRecipientQuestion,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.walletTransferRecipientWalletActive,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.walletTransferPhoneNumber,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 5),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+212',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '6 00 00 00 00',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.walletTransferContinue,
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

  // ─── STEP 1 : MONTANT ───

  Widget _buildAmountStep() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD11A2A),
                Color(0xFFA8161F),
                Color(0xFF6E0B12),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'AB',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _recipient,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.walletTransferAmountToSend,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                textAlign: TextAlign.right,
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
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.6,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [50, 100, 200, 500].map((v) {
            final on = _amount == v.toString();

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: v == 500 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => setState(
                        () => _amount = v.toString(),
                  ),
                  child: Container(
                    height: 40,
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
                        fontSize: 12,
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
        Text(
          l10n.walletTransferOptionalMessage,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _noteCtrl,
          maxLength: 60,
          cursorColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: l10n.walletTransferNoteHint,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
            counterStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: Colors.white.withOpacity(0.4),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.walletTransferContinue,
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

  // ─── STEP 2 : PIN ───

  Widget _buildPinStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: Column(
            children: [
              Text(
                l10n.walletTransferYouSend,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
              const SizedBox(height: 6),
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
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              _kv(l10n.walletTransferBeneficiary, _recipient),
              if (_note.isNotEmpty) ...[
                const SizedBox(height: 8),
                _kv(l10n.walletTransferMessage, _note),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.walletTransferEnterPin,
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
          onChanged: (v) => setState(() => _pin = v),
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
            onPressed: _isLoading ? null : _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            )
                : Text(
              l10n.walletTransferConfirm,
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

  // ─── STEP 3 : SUCCÈS ───

  Widget _buildSuccessStep() {
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
            Icons.send,
            color: Color(0xFFF5CD52),
            size: 32,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.walletTransferCreditSent,
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
          l10n.walletTransferToRecipient(_recipient),
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
                l10n.walletTransferDate,
                DateTime.now().toString().substring(0, 16),
              ),
              const SizedBox(height: 8),
              _kv(l10n.walletTransferPhone, _recipient),
              const SizedBox(height: 8),
              _kv(
                l10n.walletTransferReference,
                '[RÉFÉRENCE]',
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
              l10n.walletTransferBackToWallet,
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