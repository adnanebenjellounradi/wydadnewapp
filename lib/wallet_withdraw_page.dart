import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'wallet_service.dart';

class WalletWithdrawPage extends StatefulWidget {
  final String token;

  const WalletWithdrawPage({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletWithdrawPage> createState() => _WalletWithdrawPageState();
}

class _WalletWithdrawPageState extends State<WalletWithdrawPage> {
  final Color primary = const Color(0xFFA8161F);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _isLoading = true;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);

    final wallet = await WalletService.getWalletInfo(widget.token);

    if (!mounted) return;

    setState(() {
      _balance = (wallet?['balance'] as num?)?.toDouble() ?? 0;
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
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.walletWithdrawChooseMethod,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.walletWithdrawAvailableBalance(
                          _balance
                              .toStringAsFixed(2)
                              .replaceAll('.', ','),
                        ),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _methodCard(
                        icon: Icons.account_balance_outlined,
                        title: l10n.walletWithdrawBankAccount,
                        subtitle: l10n.walletWithdrawBankSubtitle,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/walletWithdrawBank',
                            arguments: {'token': widget.token},
                          );
                          _loadBalance();
                        },
                      ),
                      const SizedBox(height: 10),
                      _methodCard(
                        icon: Icons.payments_outlined,
                        title: l10n.walletWithdrawCashAgency,
                        subtitle: l10n.walletWithdrawCashSubtitle,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/walletWithdrawCash',
                            arguments: {'token': widget.token},
                          );
                          _loadBalance();
                        },
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
            l10n.walletWithdrawTitle,
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
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}