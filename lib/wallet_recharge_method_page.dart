import 'package:flutter/material.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletRechargeMethodPage extends StatefulWidget {
  final String token;
  const WalletRechargeMethodPage({Key? key, required this.token})
      : super(key: key);

  @override
  State<WalletRechargeMethodPage> createState() =>
      _WalletRechargeMethodPageState();
}

class _WalletRechargeMethodPageState extends State<WalletRechargeMethodPage> {
  final Color primary = const Color(0xFFA8161F);
  bool _isLoading = true;
  double _balance = 0;

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final w = await WalletService.getWalletInfo(widget.token);
    if (!mounted) return;
    setState(() {
      _balance = (w?['balance'] as num?)?.toDouble() ?? 0;
      _isLoading = false;
    });
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
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: Column(
                    children: [
                      _buildIcon(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.howToTopUpQuestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.currentBalanceFormat(
                            _balance
                                .toStringAsFixed(2)
                                .replaceAll('.', ',')),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _methodCard(
                        icon: Icons.credit_card,
                        title: l10n.bankCardMethod,
                        subtitle: l10n.bankCardMethodSubtitle,
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, '/walletRecharge',
                              arguments: {'token': widget.token});
                          _load();
                        },
                      ),
                      const SizedBox(height: 10),
                      _methodCard(
                        icon: Icons.account_balance_outlined,
                        title: l10n.bankTransferMethod,
                        subtitle: l10n.bankTransferMethodSubtitle,
                        onTap: () => Navigator.pushNamed(
                            context, '/walletRechargeRib',
                            arguments: {'token': widget.token}),
                      ),
                      const SizedBox(height: 10),
                      _methodCard(
                        icon: Icons.payments_outlined,
                        title: l10n.cashAtAgency,
                        subtitle: l10n.cashAgencyMethodSubtitle,
                        onTap: () => Navigator.pushNamed(
                            context, '/walletRechargeCash',
                            arguments: {'token': widget.token}),
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
            l10n.topUpMyAccount,
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

  Widget _buildIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Icon(Icons.add_card, color: Colors.white, size: 32),
    );
  }

  Widget _methodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        constraints: const BoxConstraints(minHeight: 76),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}