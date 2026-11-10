import 'package:flutter/material.dart';
import 'login.dart';
import 'inscription.dart';
import 'acceuil.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({Key? key}) : super(key: key);

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_SlideData> _slides = [
    _SlideData(
      title: 'Une seule appli,\npour tout faire',
      text: 'Billetterie, Ticketplace et Fan Zone réunis au même endroit.',
    ),
    _SlideData(
      title: 'Payez tout, partout',
      text:
      "Alimentez, transférez, retirez et rechargez votre mobile avec Wydad Pay. Votre carte d'abonnement vous suit partout.",
    ),
    _SlideData(
      title: 'Vivez chaque match',
      text:
      'Votez pour votre joueur favori, jouez au quiz et gagnez des billets.',
    ),
  ];

  bool get _isLast => _currentPage == _slides.length - 1;

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding(BuildContext context, Widget next) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            // Top radial red glow
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
              child: Column(
                children: [
                  // Skip button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: 36,
                        child: TextButton(
                          onPressed: () {
                            _finishOnboarding(
                              context,
                              AcceuilPage(
                                token: '',
                                toggleTheme: _noop,
                                setLanguage: _noopLang,
                                isDarkMode: false,
                                currentLocale: 'fr',
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Passer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xC7FFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Slide area
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        // Slides 1 & 2 are larger, slide 3 is compact
                        final isLast = index == 2;
                        final illustrationHeight =
                        isLast ? 240.0 : 300.0;
                        final titleFontSize = isLast ? 20.0 : 22.0;
                        final textFontSize = isLast ? 13.0 : 14.0;

                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              // Illustration
                              SizedBox(
                                height: illustrationHeight,
                                child: Center(
                                  child: _buildIllustration(index),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Title
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                child: Text(
                                  _slides[index].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                child: ConstrainedBox(
                                  constraints:
                                  const BoxConstraints(maxWidth: 320),
                                  child: Text(
                                    _slides[index].text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.72),
                                      fontSize: textFontSize,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final selected = i == _currentPage;
                      return GestureDetector(
                        onTap: () => _goToSlide(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: selected ? 24 : 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      children: [
                        if (!_isLast)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFA8161F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Suivant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _finishOnboarding(
                                      context,
                                      InscriptionPage(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFA8161F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Créer un compte',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _finishOnboarding(
                                      context,
                                      LoginPage(),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                    Colors.white.withOpacity(0.06),
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.22),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "J'ai déjà un compte",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: TextButton(
                                  onPressed: () {
                                    _finishOnboarding(
                                      context,
                                      AcceuilPage(
                                        token: '',
                                        toggleTheme: _noop,
                                        setLanguage: _noopLang,
                                        isDarkMode: false,
                                        currentLocale: 'fr',
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Continuer sans compte',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xC7FFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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

  // ---------- Illustrations ----------

  Widget _buildIllustration(int index) {
    switch (index) {
      case 0:
        return _TicketIllustration();
      case 1:
        return _WydadPayIllustration();
      case 2:
        return _FanZoneIllustration();
      default:
        return const SizedBox();
    }
  }
}

void _noop() {}
void _noopLang(String _) {}

class _SlideData {
  final String title;
  final String text;
  const _SlideData({required this.title, required this.text});
}

// ============================================================
// ILLUSTRATION 1 : Tickets / Ticketplace  (enlarged)
// ============================================================
class _TicketIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 300,
      child: Stack(
        children: [
          // Card left — Ticketplace
          Positioned(
            left: -6,
            top: 22,
            child: Transform.rotate(
              angle: -10 * 3.14159265 / 180,
              child: _TicketCard(
                smallLabel: 'TICKETPLACE',
                title: 'Revente',
                priceLabel: 'dès',
                priceValue: '70 MAD',
                icon: Icons.swap_horiz,
                gradientColors: const [
                  Color(0xFF5E0A13),
                  Color(0xFF2E0409),
                ],
                iconBg: const [Color(0xFFB0141F), Color(0xFF860D16)],
              ),
            ),
          ),
          // Card right — Fan Zone (Homme du match)
          Positioned(
            right: -6,
            top: 12,
            child: Transform.rotate(
              angle: 9 * 3.14159265 / 180,
              child: _TicketCard(
                smallLabel: 'FAN ZONE',
                title: 'Homme du match',
                badge: '● LIVE · VOTEZ',
                icon: Icons.star_border,
                gradientColors: const [
                  Color(0xFF8E1019),
                  Color(0xFF4A0710),
                ],
                iconBg: [
                  Colors.white.withOpacity(0.16),
                  Colors.white.withOpacity(0.16),
                ],
              ),
            ),
          ),
          // Central Premium ticket
          Positioned(
            left: 75,
            top: 110,
            child: _PremiumTicket(),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String smallLabel;
  final String title;
  final String? priceLabel;
  final String? priceValue;
  final String? badge;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> iconBg;

  const _TicketCard({
    required this.smallLabel,
    required this.title,
    this.priceLabel,
    this.priceValue,
    this.badge,
    required this.icon,
    required this.gradientColors,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 142,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 32,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: iconBg,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      smallLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (priceLabel != null && priceValue != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  priceLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  priceValue!,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          if (badge != null)
            Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Color(0xFFA8161F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumTicket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      height: 178,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.26)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 48,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BILLET',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: Colors.white.withOpacity(0.82),
                    ),
                  ),
                  const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 42,
                child: Image.asset(
                  'assets/739679bd3a8e68433f6bcda33167a31e.svg',
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ],
          ),
          Container(
            height: 0,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complexe Mohammed V',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Text(
                    'Porte 4 · Place 112',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ILLUSTRATION 2 : Wydad Pay  (enlarged)
// ============================================================
class _WydadPayIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Column(
        children: [
          SizedBox(
            width: 280,
            height: 195,
            child: Stack(
              children: [
                // Back card
                Positioned(
                  left: 14,
                  right: 14,
                  top: 120,
                  height: 75,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5E0A13), Color(0xFF2E0409)],
                      ),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.16)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ABONNEMENT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const Text(
                              'Saison 2026 / 27',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 26,
                          child: Image.asset(
                            'assets/739679bd3a8e68433f6bcda33167a31e.svg',
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Front card
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 145,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD11A2A),
                          Color(0xFFA8161F),
                          Color(0xFF6E0B12),
                        ],
                      ),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.24)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x8C000000),
                          blurRadius: 42,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WYDAD PAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solde disponible',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '1 250,00 ',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'MAD',
                                    style: TextStyle(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: 280,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _PayAction(
                  icon: Icons.add,
                  label: 'Alimenter',
                  highlighted: true,
                ),
                _PayAction(
                  icon: Icons.send_outlined,
                  label: 'Transférer',
                ),
                _PayAction(
                  icon: Icons.account_balance_outlined,
                  label: 'Retirer',
                ),
                _PayAction(
                  icon: Icons.grid_view_rounded,
                  label: 'Plus',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _PayAction({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: highlighted
                  ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB0141F), Color(0xFF860D16)],
              )
                  : null,
              color: highlighted ? null : Colors.white.withOpacity(0.10),
              border: Border.all(
                color: highlighted
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.16),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ILLUSTRATION 3 : Fan Zone  (kept compact so text fits)
// ============================================================
class _FanZoneIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 235,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vote card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.07),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Joueur du match',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5484D),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _VoteBar(
                  percentage: 62,
                  filledColor: Colors.white,
                  avatarGradient: true,
                ),
                const SizedBox(height: 6),
                _VoteBar(
                  percentage: 38,
                  filledColor: Colors.white.withOpacity(0.5),
                  avatarGradient: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Quiz card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD11A2A),
                        Color(0xFFA8161F),
                        Color(0xFF6E0B12),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.star_border,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiz du jour',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2 billets à gagner',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  final int percentage;
  final Color filledColor;
  final bool avatarGradient;

  const _VoteBar({
    required this.percentage,
    required this.filledColor,
    required this.avatarGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: avatarGradient
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD11A2A),
                Color(0xFFA8161F),
                Color(0xFF6E0B12),
              ],
            )
                : null,
            color: avatarGradient ? null : Colors.white.withOpacity(0.16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 7,
                  color: Colors.white.withOpacity(0.1),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 7,
                    color: filledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$percentage %',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}