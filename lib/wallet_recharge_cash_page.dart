import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletRechargeCashPage extends StatefulWidget {
  final String token;
  const WalletRechargeCashPage({Key? key, required this.token})
      : super(key: key);

  @override
  State<WalletRechargeCashPage> createState() => _WalletRechargeCashPageState();
}

class _WalletRechargeCashPageState extends State<WalletRechargeCashPage> {
  final Color primary = const Color(0xFFA8161F);

  int _step = 0;
  bool _isSubmitting = false;

  final TextEditingController _amountCtrl = TextEditingController(text: '300');

  String _amount = '300';
  String? _depositCode;

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() {
      setState(() {
        _amount = _amountCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _submit() async {
    if (_amountValue < 50) {
      _showError(l10n.minAmount50);
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final res = await WalletService.rechargeAgency(
        token: widget.token,
        amount: _amountValue,
        description: l10n.cashAgencyDescription,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      print("🔍 [RECHARGE AGENCY] API response = $res");

      if (res != null && res['success'] == true) {
        final data = res['data'];

        final code = data?['deposit_code']?.toString() ??
            data?['code']?.toString() ??
            data?['reference']?.toString() ??
            '------';

        setState(() {
          _depositCode = code;
          _step = 1;
        });
      } else {
        _showError(res?['message']?.toString() ??
            l10n.operationFailedContactSupport);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      print("🔍 [RECHARGE AGENCY] Error = $e");
      _showError(l10n.connectionErrorRetry);
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: _step == 0 ? _buildFormStep() : _buildCodeStep(),
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
            l10n.cashAtAgency,
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

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.amountToDeposit,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
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
          children: [100, 200, 500, 1000].map((v) {
            final on = _amount == v.toString();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: v == 1000 ? 0 : 8),
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
                      v == 1000 ? '1 000' : '$v',
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
            Icon(Icons.storefront_outlined,
                color: Colors.white.withOpacity(0.6), size: 14),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.cashAgencyInfo,
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
              l10n.getMyDepositCode,
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

  Widget _buildCodeStep() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.presentCodeAndCin,
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
                l10n.depositCodeLabel,
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
                _depositCode ?? '------',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                  color: Color(0xFFA8161F),
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.black.withOpacity(0.10)),
              const SizedBox(height: 10),
              _kvWhite(l10n.amountLabel, '$_amount,00 MAD'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFFFC97A).withOpacity(0.10),
            border:
            Border.all(color: const Color(0xFFFFC97A).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFFFFC97A), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.balanceWillBeCredited,
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
            onPressed: () => Navigator.of(context, rootNavigator: true)
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
              l10n.backToHome,
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