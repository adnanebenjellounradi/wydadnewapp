import 'package:flutter/material.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletAccountPage extends StatefulWidget {
  final String token;

  const WalletAccountPage({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletAccountPage> createState() => _WalletAccountPageState();
}

class _WalletAccountPageState extends State<WalletAccountPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? _kyc;

  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final wallet = await WalletService.getWalletInfo(widget.token);
    final kyc = await WalletService.getKycStatus(widget.token);
    if (!mounted) return;
    setState(() {
      _wallet = wallet;
      _kyc = kyc;
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    children: [
                      _buildAccountCard(),
                      const SizedBox(height: 12),
                      _buildKycSection(),
                      const SizedBox(height: 12),
                      _buildActions(),
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
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            l10n.myAccount,
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

  Widget _buildAccountCard() {
    final fullName = _wallet?['full_name']?.toString() ?? '';
    final phone = _wallet?['phone']?.toString() ?? '';
    final isVerified = (_wallet?['is_verified'] as bool?) ?? false;
    final level = (_wallet?['account_level'] as int?) ?? 1;
    final accountType =
        _wallet?['account_type']?.toString() ?? l10n.defaultAccountType;
    final currentLimit =
        (_wallet?['limits']?['current_limit'] as num?)?.toDouble() ?? 1000;

    final initials = fullName.isNotEmpty
        ? fullName
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join()
        : 'AB';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                alignment: Alignment.center,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : l10n.namePlaceholder,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone.isNotEmpty ? phone : '—',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: const Color(0xFFF5CD52).withOpacity(0.14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check,
                          color: Color(0xFFF5CD52), size: 10),
                      const SizedBox(width: 3),
                      Text(
                        l10n.verified,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF5CD52),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.10)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoCell(l10n.accountType, accountType),
              _infoCell(l10n.accountLevel,
                  l10n.accountLevelWithValue('$level')),
              _infoCell(l10n.accountLimit,
                  '${currentLimit.toStringAsFixed(0)} MAD'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycSection() {
    final progress = _computeKycProgress();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.identityVerification,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progress * 100).round()} %',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor:
              const AlwaysStoppedAnimation(Color(0xFFF5CD52)),
            ),
          ),
          const SizedBox(height: 10),
          _checkRow(l10n.kycPhoneVerified, done: true),
          _checkRow(l10n.kycPersonalInfo, done: true),
          _checkRow(l10n.kycAddress, done: true),
          _checkRow(l10n.kycCin, done: false),
          _checkRow(l10n.kycSelfie, done: false),
        ],
      ),
    );
  }

  double _computeKycProgress() {
    final level = (_wallet?['account_level'] as int?) ?? 1;
    if (level >= 2) return 1.0;
    if (level == 1) return 0.6;
    return 0.0;
  }

  Widget _checkRow(String label, {required bool done}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? const Color(0xFFF5CD52) : Colors.transparent,
              border: done
                  ? null
                  : Border.all(
                  color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: done
                ? const Icon(Icons.check,
                size: 10, color: Color(0xFF07060F))
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color:
              done ? Colors.white : Colors.white.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        _actionTile(
          icon: Icons.lock_outline,
          label: l10n.changePin,
          onTap: () {
            Navigator.pushNamed(context, '/walletChangePin', arguments: {
              'token': widget.token,
            });
          },
        ),
        const SizedBox(height: 8),
        _actionTile(
          icon: Icons.power_settings_new,
          label: l10n.logoutWalletSession,
          onTap: () async {
            await WalletService.logout(widget.token);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.walletSessionClosed,
                      style: const TextStyle(fontFamily: 'Inter')),
                  backgroundColor: primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
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