import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  final String token;
  final String? organizationId;

  const WalletPage({Key? key, required this.token, this.organizationId})
      : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  bool _showAbo = false;
  String _userName = '';

  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadWallet();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = '${prefs.getString('user_name') ?? ''} '
          '${prefs.getString('user_last_name') ?? ''}'
          .trim();
    });
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoading = true);
    final data = await WalletService.getWalletInfo(widget.token);
    final tx = await WalletService.getTransactions(widget.token);
    if (!mounted) return;
    setState(() {
      _wallet = data;
      _transactions = tx;
      _isLoading = false;
    });
  }

  double get _balance => (_wallet?['balance'] as num?)?.toDouble() ?? 0;
  int get _level => (_wallet?['account_level'] as int?) ?? 1;
  bool get _isVerified => (_wallet?['is_verified'] as bool?) ?? false;
  String get _phone => _wallet?['phone']?.toString() ?? '';
  String get _fullName => _wallet?['full_name']?.toString() ?? _userName;

  Future<void> _showComingSoonModal() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext dialogContext) {
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
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8B10E).withOpacity(0.14),
                    border: Border.all(
                      color: const Color(0xFFE8B10E).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFF5CD52),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.comingSoon,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.subscriptionComingSoonMessage,
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
                    onTap: () => Navigator.of(dialogContext).pop(),
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
                          l10n.gotIt,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A0710),
                  Color(0xFF23030A),
                  Color(0xFF120104)
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),
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
                    padding:
                    const EdgeInsets.fromLTRB(16, 14, 16, 140),
                    child: _showAbo
                        ? _buildAboCard()
                        : _buildWalletContent(),
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading)
            Positioned(
              left: 16,
              right: 16,
              bottom: 30,
              child: _buildSwitchPill(),
            ),
        ],
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
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Image.asset(
              'assets/logo1.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.wydadPay,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/walletAccount', arguments: {
                'token': widget.token,
              });
            },
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: const Color(0xFFE8B10E).withOpacity(0.14),
                border: Border.all(
                    color: const Color(0xFFE8B10E).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Text(
                    '${l10n.levelLabel} ',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5CD52),
                    ),
                  ),
                  Text(
                    '$_level',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5CD52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceCard(),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 18),
        _buildTransactions(),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.digitalWallet,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      if (_isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Text(
                            l10n.verifiedBadge,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.availableBalanceLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.82),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _balance
                                  .toStringAsFixed(2)
                                  .replaceAll('.', ','),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                color: Colors.white,
                              ),
                            ),
                            const TextSpan(
                              text: ' MAD',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/walletChangeAccount',
                          arguments: {'token': widget.token});
                    },
                    child: Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.22),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _phone.isNotEmpty
                                ? _phone
                                : l10n.phoneMaskPlaceholder,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 12),
                        ],
                      ),
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

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': l10n.topUp,
        'icon': Icons.add,
        'onTap': () async {
          await Navigator.pushNamed(
            context,
            '/walletRechargeMethod',
            arguments: {'token': widget.token},
          );
          _loadWallet();
        },
      },
      {
        'label': l10n.transferAction,
        'icon': Icons.send_outlined,
        'onTap': () => Navigator.pushNamed(context, '/walletTransfer',
            arguments: {'token': widget.token}),
      },
      {
        'label': l10n.withdraw,
        'icon': Icons.account_balance_outlined,
        'onTap': () => Navigator.pushNamed(context, '/walletWithdraw',
            arguments: {'token': widget.token}),
      },
      {
        'label': l10n.moreAction,
        'icon': Icons.grid_view_rounded,
        'onTap': () => Navigator.pushNamed(context, '/walletAllServices',
            arguments: {'token': widget.token}),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final isPrimary = a['label'] == l10n.topUp;
        return GestureDetector(
          onTap: a['onTap'] as VoidCallback,
          child: SizedBox(
            width: 68,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isPrimary
                        ? Colors.white
                        : Colors.white.withOpacity(0.07),
                    border: isPrimary
                        ? null
                        : Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Icon(
                    a['icon'] as IconData,
                    color: isPrimary ? primary : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  a['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.latestOperations,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/walletHistory',
                  arguments: {'token': widget.token}),
              child: Text(
                l10n.seeAll,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: _transactions.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.noOperation,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          )
              : Column(
            children: List.generate(
              _transactions.take(3).length,
                  (i) {
                final tx = _transactions[i];
                final isLast =
                    i == _transactions.take(3).length - 1;
                return _buildTxRow(tx, isLast: isLast);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTxRow(Map<String, dynamic> tx, {bool isLast = false}) {
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final type = tx['type']?.toString() ?? 'unknown';
    final isIncome = type == 'recharge' || type == 'received' || amount > 0;
    final label =
        tx['description']?.toString() ?? tx['label']?.toString() ?? type;
    final date = tx['created_at']?.toString() ?? '';
    final dateFormatted = date.length > 16
        ? date.substring(0, 16).replaceAll('T', ' · ')
        : date;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isIncome
                  ? const Color(0xFFF5CD52).withOpacity(0.14)
                  : Colors.white.withOpacity(0.10),
            ),
            child: Icon(
              isIncome ? Icons.add : Icons.remove,
              color: isIncome ? const Color(0xFFF5CD52) : Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '−'} ${amount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isIncome ? const Color(0xFFF5CD52) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showComingSoonModal,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 165,
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
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.subscriptionLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                    color: Color(0xBFFFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.season2026_27,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                              child: Image.asset(
                                'assets/logo1.png',
                                errorBuilder: (_, __, ___) =>
                                const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullName.isNotEmpty
                                      ? _fullName
                                      : l10n.supporterNamePlaceholder,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  l10n.tribuneInfoPlaceholder,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.72),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.qr_code_2,
                                  color: Color(0xFFA8161F), size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildAboOptions(),
      ],
    );
  }

  Widget _buildAboOptions() {
    final options = [
      {
        'icon': Icons.qr_code_2,
        'label': l10n.showQRAccess,
        'onTap': _showComingSoonModal,
      },
      {
        'icon': Icons.event,
        'label': l10n.nextMatch,
        'onTap': () {
          Navigator.pushNamed(context, '/events', arguments: {
            'token': widget.token,
            'organizationId': widget.organizationId,
          });
        }
      },
      {
        'icon': Icons.swap_horiz,
        'label': l10n.resellMatch,
        'onTap': _showComingSoonModal,
      },
      {
        'icon': Icons.info_outline,
        'label': l10n.subscriptionDetails,
        'onTap': _showComingSoonModal,
      },
      {
        'icon': Icons.refresh,
        'label': l10n.renewSubscription,
        'onTap': _showComingSoonModal,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        children: List.generate(options.length, (i) {
          final opt = options[i];
          final isLast = i == options.length - 1;
          return GestureDetector(
            onTap: opt['onTap'] as VoidCallback,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i == 0
                          ? primary
                          : Colors.white.withOpacity(0.12),
                    ),
                    child: Icon(opt['icon'] as IconData,
                        color: Colors.white, size: 15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: Colors.white.withOpacity(0.6), size: 14),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSwitchPill() {
    return GestureDetector(
      onTap: () {
        if (_showAbo) {
          setState(() => _showAbo = false);
        } else {
          _showComingSoonModal();
        }
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          gradient: _showAbo
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD11A2A),
              Color(0xFFA8161F),
              Color(0xFF6E0B12)
            ],
          )
              : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5E0A13), Color(0xFF2E0409)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showAbo ? l10n.wydadPay : l10n.subscriptionLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Colors.white.withOpacity(_showAbo ? 0.85 : 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _showAbo
                      ? '${_balance.toStringAsFixed(2).replaceAll('.', ',')} MAD'
                      : l10n.season2026_27,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 28,
              child: Image.asset(
                'assets/logo1.png',
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}