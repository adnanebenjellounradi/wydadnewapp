import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ticketplace_service.dart';

class PublishResaleScreen extends StatefulWidget {
  final String token;
  final List<int> orderChildIds;
  final double originalPrice;
  final String matchName;

  const PublishResaleScreen({
    Key? key,
    required this.token,
    required this.orderChildIds,
    required this.originalPrice,
    required this.matchName,
  }) : super(key: key);

  @override
  State<PublishResaleScreen> createState() => _PublishResaleScreenState();
}

class _PublishResaleScreenState extends State<PublishResaleScreen> {
  final _priceCtrl = TextEditingController(text: '70');
  Map<String, dynamic>? _pricing;
  bool _publishing = false;

  double get _max => widget.originalPrice * 2;
  double get _entered => double.tryParse(_priceCtrl.text) ?? 0;
  bool get _over => _entered > _max;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _calc() async {
    if (_entered <= 0) return;
    final p = await TicketplaceService.calculatePricing(token: widget.token, resalePrice: _entered);
    if (mounted) setState(() => _pricing = p);
  }

  Future<void> _publish() async {
    if (_over) return;
    setState(() => _publishing = true);
    final res = await TicketplaceService.publishResale(
      token: widget.token,
      orderChildIds: widget.orderChildIds,
      resalePrice: _entered,
    );
    setState(() => _publishing = false);

    if (res != null && res['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annonce publiée avec succès !'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res?['message'] ?? 'Erreur lors de la publication'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final net = _pricing?['seller_net_amount'] ?? (_entered * 0.95);
    final fee = _pricing?['seller_fee'] ?? (_entered * 0.05);

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Revendre mon billet', style: TextStyle(color: Colors.white, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)),
            child: Text(widget.matchName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 22),
          const Text('Votre prix de vente', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _over ? Colors.redAccent : Colors.white24, width: 1.5),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (_) { setState(() {}); _calc(); },
                ),
              ),
              const Text('MAD', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            _over ? 'Le prix ne peut pas dépasser ${_max.toStringAsFixed(0)} MAD' : 'Prix max : ${_max.toStringAsFixed(0)} MAD (2× prix d\'origine)',
            style: TextStyle(color: _over ? Colors.redAccent : Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
            child: Column(children: [
              _row('Prix de vente', '${_entered.toStringAsFixed(2)} MAD'),
              _row('Frais vendeur (5%)', '−${fee.toStringAsFixed(2)} MAD'),
              const Divider(color: Colors.white12),
              _row('Versé sur Wallet', '${net.toStringAsFixed(2)} MAD', highlight: true),
            ]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_over || _publishing) ? null : _publish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFA8161F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _publishing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA8161F)))
                : const Text("Publier l'annonce", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool highlight = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      Text(v, style: TextStyle(color: highlight ? const Color(0xFFF5CD52) : Colors.white, fontSize: highlight ? 20 : 14, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
    ]),
  );
}