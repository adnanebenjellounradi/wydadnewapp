import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_service.dart';
import 'cmi_payment_wallet.dart';

class WalletRechargePage extends StatefulWidget {
  final String token;
  const WalletRechargePage({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletRechargePage> createState() => _WalletRechargePageState();
}

class _WalletRechargePageState extends State<WalletRechargePage> {
  // 0: montant, 1: choix méthode, 2: sélection carte, 3: CVV, 4: succès
  int _step = 0;
  String _amount = '200';
  bool _isLoading = false;
  String _paymentMethod = 'chari'; // 'chari' ou 'cmi'

  List<Map<String, dynamic>> _savedCards = [];
  Map<String, dynamic>? _selectedCard;

  final Color primary = const Color(0xFFA8161F);
  final TextEditingController _cvvCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSavedCards();
  }

  @override
  void dispose() {
    _cvvCtrl.dispose();
    super.dispose();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  Future<void> _fetchSavedCards() async {
    final cards = await WalletService.getCards(widget.token);
    if (mounted) {
      setState(() {
        _savedCards = cards;
      });
    }
  }

  void _goNext() async {
    if (_step == 0) {
      if (_amountValue < 50 || _amountValue > 1000) {
        _showError('Montant entre 50 et 1000 MAD (niveau 1)');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      // Choix de la méthode effectué, on passe à la sélection de carte
      if (_savedCards.isEmpty) {
        _showError('Aucune carte enregistrée.');
        return;
      }
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (_selectedCard == null) {
        _showError('Veuillez sélectionner une carte');
        return;
      }
      setState(() => _step = 3);
    } else if (_step == 3) {
      if (_cvvCtrl.text.length < 3) {
        _showError('CVV invalide');
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
        _showError(res?['message']?.toString() ?? 'Recharge refusée');
        return;
      }

      final data = res['data'];
      final rechargeId = data['recharge_id'];
      final reference = data['reference']?.toString() ?? '';
      final redirectUrl = data['redirect_url']?.toString() ?? '';

      if (redirectUrl.isEmpty) {
        _showError('Lien de paiement manquant');
        return;
      }

      await Navigator.push(
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Erreur: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
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
                  child: _step == 0
                      ? _buildAmountStep()
                      : _step == 1
                      ? _buildPaymentMethodChoice()
                      : _step == 2
                      ? _buildCardSelectionStep()
                      : _step == 3
                      ? _buildCvvStep()
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
              if (_step > 0 && _step < 4) {
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
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            _step == 4 ? 'Succès' : 'Recharger',
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

  // ─── STEP 0 : MONTANT ───
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
                'Wydad Pay',
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
          'Montant à recharger',
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
                  ..selection = TextSelection.collapsed(offset: _amount.length),
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
          'Plafond par transaction : 1 000 MAD (niveau 1)',
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
                  onTap: () => setState(() => _amount = v.toString()),
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
            const Text(
              'Total à payer',
              style: TextStyle(
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
            child: const Text(
              'Continuer',
              style: TextStyle(
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

  // ─── STEP 1 : CHOIX MÉTHODE ───
  Widget _buildPaymentMethodChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Mode de paiement',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Comment souhaitez-vous régler $_amount,00 MAD ?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        _buildMethodCard(
          icon: Icons.credit_card,
          title: 'Payer par Chari (Carte)',
          subtitle: 'Paiement sécurisé par carte bancaire',
          isSelected: _paymentMethod == 'chari',
          onTap: () => setState(() => _paymentMethod = 'chari'),
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          icon: Icons.public,
          title: 'Payer par CMI',
          subtitle: 'Redirection vers le portail CMI',
          isSelected: _paymentMethod == 'cmi',
          onTap: () => setState(() => _paymentMethod = 'cmi'),
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
              _paymentMethod == 'chari' ? 'Payer par Chari' : 'Payer par CMI',
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

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.14),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFF5CD52)),
          ],
        ),
      ),
    );
  }

  // ─── STEP 2 : SÉLECTION DE LA CARTE ───
  Widget _buildCardSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Carte de paiement',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez la carte pour payer $_amount,00 MAD',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        if (_savedCards.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: const Center(
              child: Text(
                'Aucune carte enregistrée dans votre compte.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
              ),
            ),
          )
        else
          ..._savedCards.map((card) {
            final isSelected = _selectedCard?['customerTokenizedCardId'] == card['customerTokenizedCardId'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCard = card),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.14),
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
                      child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['scheme'] ?? 'Carte',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card['maskedPan'] ?? '•••• •••• •••• ••••',
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
                      const Icon(Icons.check_circle, color: Color(0xFFF5CD52)),
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
            child: const Text(
              'Continuer',
              style: TextStyle(
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

  // ─── STEP 3 : CVV ───
  Widget _buildCvvStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Confirmation',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saisissez le cryptogramme (CVV) pour valider le paiement par ${_paymentMethod == 'chari' ? 'Chari' : 'CMI'}.',
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
                '${_selectedCard!['scheme'] ?? 'Carte'} ${_selectedCard!['maskedPan'] ?? ''}',
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
            hintText: '•••',
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
              _paymentMethod == 'chari' ? 'Payer par Chari' : 'Payer par CMI',
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
    return const Center(
      child: Text(
        'Recharge effectuée',
        style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }
}