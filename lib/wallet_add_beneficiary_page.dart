import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_service.dart';

class WalletAddBeneficiaryPage extends StatefulWidget {
  final String token;
  final String? defaultPhone; // téléphone du wallet (obligatoire côté API)
  const WalletAddBeneficiaryPage({
    Key? key,
    required this.token,
    this.defaultPhone,
  }) : super(key: key);

  @override
  State<WalletAddBeneficiaryPage> createState() =>
      _WalletAddBeneficiaryPageState();
}

class _WalletAddBeneficiaryPageState extends State<WalletAddBeneficiaryPage> {
  final Color primary = const Color(0xFFA8161F);

  final _nameCtrl = TextEditingController();
  final _ribCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _useWalletPhone = true;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.defaultPhone ?? '';
    _useWalletPhone = (widget.defaultPhone?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ribCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final rib = _ribCtrl.text.replaceAll(' ', '');
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      _showError('Nom du compte requis');
      return;
    }
    if (rib.length != 24) {
      _showError('Le RIB doit contenir 24 chiffres');
      return;
    }
    if (phone.length < 9) {
      _showError('Numéro de téléphone requis');
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await WalletService.addBeneficiary(
      token: widget.token,
      name: name,
      rib: rib,
      recipientPhone:
      phone.startsWith('+') ? phone : '+212${phone.replaceAll(' ', '')}',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res != null && res['success'] == true) {
      Navigator.pop(context, true); // true = succès, la page R2 rechargera
    } else {
      _showError(res?['message']?.toString() ?? 'Ajout échoué');
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter un compte à mon nom',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Le compte doit être à votre nom. Les retraits seront envoyés sur ce RIB.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _darkField(
                        label: 'Nom du compte',
                        hint: 'Ex. Mon Compte Attijari',
                        controller: _nameCtrl,
                      ),
                      const SizedBox(height: 12),
                      _darkField(
                        label: 'RIB (24 chiffres)',
                        hint: '000 000 0000000000000000 00',
                        controller: _ribCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _useWalletPhone,
                            onChanged: (v) => setState(() {
                              _useWalletPhone = v ?? false;
                              if (_useWalletPhone &&
                                  (widget.defaultPhone?.isNotEmpty ?? false)) {
                                _phoneCtrl.text = widget.defaultPhone!;
                              }
                            }),
                            activeColor: primary,
                            checkColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.4)),
                          ),
                          Expanded(
                            child: Text(
                              'Utiliser le numéro du wallet',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.86),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _darkField(
                        label: 'Numéro de téléphone associé',
                        hint: '6 00 00 00 00',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        enabled: !_useWalletPhone,
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFFFC97A).withOpacity(0.10),
                          border: Border.all(
                              color: const Color(0xFFFFC97A).withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                color: Color(0xFFFFC97A), size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vérifiez bien le RIB : les retraits sont irréversibles une fois traités.',
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
                        height: 54,
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
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(primary),
                            ),
                          )
                              : const Text(
                            'Enregistrer ce compte',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
          const Text(
            'Nouveau compte bancaire',
            style: TextStyle(
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

  Widget _darkField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorColor: Colors.white,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(enabled ? 0.06 : 0.03),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}