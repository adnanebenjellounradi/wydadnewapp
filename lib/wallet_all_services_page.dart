import 'package:flutter/material.dart';

class WalletAllServicesPage extends StatelessWidget {
  final String token;

  const WalletAllServicesPage({Key? key, required this.token})
      : super(key: key);

  final Color primary = const Color(0xFFA8161F);

  @override
  Widget build(BuildContext context) {
    final available = [
      {
        'label': 'Alimenter',
        'icon': Icons.add,
        'route': '/walletRecharge',
      },
      {
        'label': 'Transférer',
        'icon': Icons.send_outlined,
        'route': '/walletTransfer',
      },
      {
        'label': 'Retirer',
        'icon': Icons.account_balance_outlined,
        'route': '/walletWithdraw',
      },
      {
        'label': 'Recharge mobile',
        'icon': Icons.smartphone,
        'route': null,
      },
      {
        'label': 'Recevoir paiement',
        'icon': Icons.qr_code_2,
        'route': null,
      },
      {
        'label': 'Historique',
        'icon': Icons.history,
        'route': '/walletHistory',
      },
      {
        'label': 'Gestion compte',
        'icon': Icons.tune,
        'route': '/walletAccount',
      },
    ];

    final soon = [
      {'label': 'Payer facture', 'icon': Icons.receipt_long},
      {'label': 'Payer commerçant', 'icon': Icons.storefront},
      {'label': 'Cartes-cadeaux', 'icon': Icons.card_giftcard},
      {'label': 'Mes cartes', 'icon': Icons.credit_card},
    ];

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
                child: _buildHeader(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('DISPONIBLES'),
                      const SizedBox(height: 12),
                      _buildGrid(context, available, disabled: false),
                      const SizedBox(height: 24),
                      _sectionTitle('BIENTÔT'),
                      const SizedBox(height: 12),
                      _buildGrid(context, soon, disabled: true),
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

  Widget _buildHeader(BuildContext context) {
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
            'Tous les services',
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Colors.white.withOpacity(0.6),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Map<String, dynamic>> items,
      {required bool disabled}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return GestureDetector(
          onTap: disabled
              ? () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '${item['label']} — Bientôt disponible',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: primary,
              behavior: SnackBarBehavior.floating,
            ));
          }
              : () {
            final route = item['route'] as String?;
            if (route != null) {
              Navigator.pushNamed(context, route, arguments: {
                'token': token,
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: disabled
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.07),
              border: Border.all(
                color: disabled
                    ? Colors.white.withOpacity(0.14)
                    : Colors.white.withOpacity(0.12),
                style: disabled ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: disabled
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color:
                    disabled ? Colors.white.withOpacity(0.45) : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? Colors.white.withOpacity(0.45)
                        : Colors.white,
                    fontFamily: 'Inter',
                    height: 1.25,
                  ),
                ),
                if (disabled) ...[
                  const SizedBox(height: 3),
                  Text(
                    'BIENTÔT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}