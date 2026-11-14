import 'package:flutter/material.dart';
import 'wallet_service.dart';
import 'l10n/app_localizations.dart';

class WalletHistoryPage extends StatefulWidget {
  final String token;
  const WalletHistoryPage({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  String _filter = 'all';

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
    final tx = await WalletService.getTransactions(widget.token);
    if (!mounted) return;
    setState(() {
      _transactions = tx;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _transactions;
    return _transactions.where((t) {
      final type = t['type']?.toString() ?? '';
      if (_filter == 'recharge') {
        return type == 'recharge' || type == 'deposit';
      }
      if (_filter == 'transfer') {
        return type == 'transfer' || type == 'sent';
      }
      if (_filter == 'received') return type == 'received';
      if (_filter == 'cashout') {
        return type == 'cashout' || type == 'withdraw';
      }
      return true;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final tx in _filtered) {
      final raw = tx['created_at']?.toString() ?? '';
      final day = raw.length > 10 ? raw.substring(0, 10) : l10n.today;
      map.putIfAbsent(day, () => []).add(tx);
    }
    return map;
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildHeader(),
              ),
              if (!_isLoading) _buildFilters(),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primary))
                    : _filtered.isEmpty
                    ? _emptyState()
                    : SingleChildScrollView(
                  padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _grouped.entries.map((e) {
                      return _buildGroup(e.key, e.value);
                    }).toList(),
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
            l10n.historyTitle,
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

  Widget _buildFilters() {
    final types = [
      {'id': 'all', 'label': l10n.all},
      {'id': 'recharge', 'label': l10n.filterRecharges},
      {'id': 'transfer', 'label': l10n.filterSent},
      {'id': 'received', 'label': l10n.filterReceived},
      {'id': 'cashout', 'label': l10n.filterCashOut},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types.map((t) {
            final on = _filter == t['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = t['id'] as String),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    t['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGroup(String day, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(
            day,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        ...items.map((tx) {
          final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
          final type = tx['type']?.toString() ?? '';
          final isIncome = type == 'recharge' ||
              type == 'received' ||
              type == 'deposit' ||
              amount > 0;
          final title = tx['description']?.toString() ??
              tx['label']?.toString() ??
              type;
          final rawDate = tx['created_at']?.toString() ?? '';
          final time =
          rawDate.length > 16 ? rawDate.substring(11, 16) : '';

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/walletTxDetail',
                arguments: {'token': widget.token, 'tx': tx}),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isIncome
                          ? const Color(0xFFF5CD52).withOpacity(0.12)
                          : Colors.white.withOpacity(0.08),
                    ),
                    child: Icon(
                      isIncome ? Icons.add : Icons.remove,
                      color:
                      isIncome ? const Color(0xFFF5CD52) : Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '−'}${amount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                      isIncome ? const Color(0xFFF5CD52) : Colors.white,
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long,
              color: Colors.white.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.noTransactions,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}