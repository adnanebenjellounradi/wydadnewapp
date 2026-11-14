import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_service.dart';
import 'cmi_payment_wallet.dart';
import 'l10n/app_localizations.dart';

class WalletRechargePage extends StatefulWidget {
  final String token;
  const WalletRechargePage({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletRechargePage> createState() => _WalletRechargePageState();
}

class _WalletRechargePageState extends State<WalletRechargePage> {
  int _step = 0;
  String _amount = '200';
  bool _isLoading = false;
  bool _isRefreshing = false;

  final TextEditingController _amountCtrl = TextEditingController(text: '200');
  final TextEditingController _cvvCtrl = TextEditingController();

  bool _isLoadingCards = true;
  String? _cardsError;
  List<Map<String, dynamic>> _savedCards = [];
  Map<String, dynamic>? _selectedCard;

  Map<String, dynamic>? _walletInfo;
  double _walletBalance = 0.0;

  final Color primary = const Color(0xFFA8161F);

  /// l10n helper
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _fetchSavedCards();
    _refreshWalletInfo();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  Future<void> _fetchSavedCards() async {
    setState(() {
      _isLoadingCards = true;
      _cardsError = null;
    });

    try {
      final cards = await WalletService.getCards(widget.token);
      if (!mounted) return;
      setState(() {
        _savedCards = cards;
        _isLoadingCards = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCards = false;
        _cardsError = l10n.cardsLoadFailed;
      });
    }
  }

  Future<void> _refreshWalletInfo() async {
    try {
      final info = await WalletService.getWalletInfo(widget.token);
      if (mounted) {
        setState(() {
          _walletInfo = info;
          _walletBalance = (info?['balance'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (_) {}
  }

  void _goNext() async {
    if (_step == 0) {
      if (_amountValue < 50 || _amountValue > 1000) {
        _showError(l10n.amountBetween50And1000);
        return;
      }
      if (_isLoadingCards) {
        _showError(l10n.loadingCardsInProgress);
        return;
      }
      if (_cardsError != null) {
        _showError(_cardsError!);
        return;
      }
      if (_savedCards.isEmpty) {
        _showError(l10n.noSavedCard);
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_selectedCard == null) {
        _showError(l10n.pleaseSelectCard);
        return;
      }
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (_cvvCtrl.text.length < 3) {
        _showError(l10n.invalidCvv);
        return;
      }
      await _processRecharge();
    }
  }

  Future<void> _processRecharge() async {
    setState(() => _isLoading = true);

    try {
      final res = await WalletService.recharge(
        token: widget.token,
        amount: _amountValue,
        cardId: _selectedCard!['customerTokenizedCardId'],
        cvv: _cvvCtrl.text,
        redirectUrl: 'https://ticketing.ma/api/customer/wallet/return',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res == null || res['success'] != true) {
        _showError(l10n.genericErrorContactSupport);
        return;
      }

      final data = res['data'];
      final rechargeId = data['recharge_id'];
      final reference = data['reference']?.toString() ?? '';
      final redirectUrl = data['redirect_url']?.toString() ?? '';

      if (redirectUrl.isEmpty) {
        _showError(l10n.genericErrorContactSupport);
        return;
      }

      final beforeInfo = await WalletService.getWalletInfo(widget.token);
      final beforeBalance =
          (beforeInfo?['balance'] as num?)?.toDouble() ?? 0.0;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CMIPaymentWebViewWallet(
            amount: _amountValue,
            token: widget.token,
            rechargeId: rechargeId is int ? rechargeId : 0,
            reference: reference,
            redirectUrl: redirectUrl,
          ),
        ),
      );

      if (!mounted) return;

      setState(() => _isRefreshing = true);
      await _refreshWalletInfo();
      if (mounted) setState(() => _isRefreshing = false);

      final balanceIncreased = _walletBalance > beforeBalance + 0.001;
      final success = result == true || balanceIncreased;

      if (success) {
        await _fetchSavedCards();
        if (mounted) setState(() => _step = 3);
      } else {
        _showError(l10n.paymentCancelledOrFailed);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(l10n.genericErrorContactSupport);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _goToHome() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/acceuil',
          (Route<dynamic> route) => false,
      arguments: {
        'token': widget.token,
      },
    );
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
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: _step == 0
                          ? _buildAmountStep()
                          : _step == 1
                          ? _buildCardSelectionStep()
                          : _step == 2
                          ? _buildCvvStep()
                          : _buildSuccessStep(),
                    ),
                  ),
                ],
              ),
              if (_isRefreshing) _buildRefreshOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5E0A13), Color(0xFF2E0409)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 30,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFF5CD52)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.updatingBalance,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
              } else if (_step == 3) {
                _goToHome();
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
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            _step == 3 ? l10n.paymentSuccess : l10n.rechargeAction,
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

  Widget _buildAmountStep() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.smartphone, color: Colors.white, size: 11),
              const SizedBox(width: 5),
              Text(
                l10n.wydadPay,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.topUpYourWalletAmount,
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
                controller: _amountCtrl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
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
        const SizedBox(height: 6),
        Text(
          l10n.transactionLimitLevel1,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [50, 100, 200, 500].map((v) {
            final on = _amount == v.toString();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: v == 500 ? 0 : 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _amount = v.toString();
                      _amountCtrl.text = v.toString();
                    });
                  },
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalToPay,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '$_amount,00 MAD',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingCards)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.loadingCards,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          )
        else if (_cardsError != null)
          TextButton.icon(
            onPressed: _fetchSavedCards,
            icon: const Icon(Icons.refresh,
                color: Color(0xFFF5CD52), size: 16),
            label: Text(
              l10n.retryLoadCards,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          )
        else if (_savedCards.isEmpty)
            TextButton.icon(
              onPressed: _fetchSavedCards,
              icon: const Icon(Icons.credit_card,
                  color: Color(0xFFF5CD52), size: 16),
              label: Text(
                l10n.noCardRefresh,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoadingCards ? null : _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              disabledBackgroundColor: Colors.white.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.continueText,
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

  Widget _buildCardSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.paymentCard,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.selectCardToPay('$_amount'),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoadingCards)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFFF5CD52)),
              ),
            ),
          )
        else if (_cardsError != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Column(
              children: [
                Text(
                  _cardsError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _fetchSavedCards,
                  icon: const Icon(Icons.refresh,
                      color: Color(0xFFF5CD52), size: 18),
                  label: Text(
                    l10n.retry,
                    style: const TextStyle(
                        color: Color(0xFFF5CD52), fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          )
        else if (_savedCards.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.credit_card_off,
                      color: Colors.white54, size: 40),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l10n.noSavedCards,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.addCardFromProfile,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'Inter',
                        fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _fetchSavedCards,
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFFF5CD52), size: 18),
                    label: Text(
                      l10n.refresh,
                      style: const TextStyle(
                          color: Color(0xFFF5CD52), fontFamily: 'Inter'),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._savedCards.map((card) {
              final isSelected = _selectedCard?['customerTokenizedCardId'] ==
                  card['customerTokenizedCardId'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCard = card),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.14),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                          ),
                        ),
                        child: const Icon(Icons.credit_card,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['scheme'] ?? l10n.cardDefault,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card['maskedPan'] ??
                                  l10n.maskedPanPlaceholder,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFFF5CD52)),
                    ],
                  ),
                ),
              );
            }).toList(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedCard == null ? null : _goNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              disabledBackgroundColor: Colors.white.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.continueText,
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

  Widget _buildCvvStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.confirmationTitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.enterCvvPrompt,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                '${_selectedCard!['scheme'] ?? l10n.cardDefault} ${_selectedCard!['maskedPan'] ?? ''}',
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
        const SizedBox(height: 16),
        TextField(
          controller: _cvvCtrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 3,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            letterSpacing: 8,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: l10n.cvvHint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
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
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 30),
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
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFA8161F),
              ),
            )
                : Text(
              l10n.pay,
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

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5CD52).withOpacity(0.14),
            border:
            Border.all(color: const Color(0xFFF5CD52).withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFF5CD52),
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.rechargeDone,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.rechargeSuccessMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.45,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.rechargedAmount,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$_amount,00 MAD',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white.withOpacity(0.12)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.newBalance,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${_walletBalance.toStringAsFixed(2).replaceAll('.', ',')} MAD',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF5CD52),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _goToHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.done,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}