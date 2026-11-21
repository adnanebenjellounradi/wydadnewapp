import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Données des slides — reprises exactement de window.__C["d2"].renderVals()
// ---------------------------------------------------------------------------
class _SlideData {
  final String image;
  final Alignment objectPosition; // équivalent CSS object-position
  final double topFraction;       // top en fraction de la hauteur écran
  final double heightFactor;      // h en fraction de la hauteur écran
  final String title;
  final String text;

  const _SlideData({
    required this.image,
    required this.objectPosition,
    required this.topFraction,
    required this.heightFactor,
    required this.title,
    required this.text,
  });
}

const List<_SlideData> _slidesData = [
  _SlideData(
    image: 'assets/firstimage.jpg',
    objectPosition: Alignment(0, 1),        // 50% 100%
    topFraction: -0.517,                    // top: -51.7%
    heightFactor: 1.53,                     // h: 153%
    title: 'Vos matchs, en poche',
    text: 'Billets, revente et QR code au même endroit.',
  ),
  _SlideData(
    image: 'assets/secondimage.jpg',
    objectPosition: Alignment(0.5, -0.4),   // 75% 30%
    topFraction: -0.047,                    // top: -4.7%
    heightFactor: 1.36,                     // h: 136%
    title: 'Payez tout, partout',
    text: 'Rechargez, transférez et payez en un geste.',
  ),
  _SlideData(
    image: 'assets/thirdimage.jpg',
    objectPosition: Alignment(-0.16, 0),    // 42% 50%
    topFraction: -0.355,                    // top: -35.5%
    heightFactor: 1.36,                     // h: 136%
    title: 'Vivez chaque match',
    text: 'Votez, jouez et gagnez des billets.',
  ),
];

// ---------------------------------------------------------------------------
// Écran de présentation (D2)
// ---------------------------------------------------------------------------
class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  int _index = 0;
  double? _pointerDownX;

  bool get _isLast => _index == _slidesData.length - 1;

  void _go(int i) {
    final clamped = i.clamp(0, _slidesData.length - 1);
    if (clamped == _index) return;
    setState(() => _index = clamped);
  }

  void _next() => _go(_index + 1);
  void _prev() => _go(_index - 1);

  void _onPointerDown(PointerDownEvent e) => _pointerDownX = e.position.dx;

  void _onPointerUp(PointerUpEvent e) {
    final start = _pointerDownX;
    _pointerDownX = null;
    if (start == null) return;
    final dx = e.position.dx - start;
    if (dx.abs() > 40) _go(dx < 0 ? _index + 1 : _index - 1);
  }

  void _goHome() {
    // Dans le proto : href="PhoneA.dc.html" → accueil.
    // Route nommée déclarée dans main.dart.
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0103),
      body: Stack(
        children: [
          // ---- Slides superposées (cross-fade 0.7s, comme .slide{transition:opacity .7s}) ----
          for (var i = 0; i < _slidesData.length; i++)
            _SlideView(
              data: _slidesData[i],
              screenHeight: size.height,
              visible: i == _index,
            ),

          // ---- Zone de swipe haute (top:80, height:480 du proto) ----
          // Listener (et non GestureDetector) : onPointerDown/Up n'existent
          // que sur Listener.
          Positioned(
            left: 0,
            right: 0,
            top: 80,
            height: 480,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
            ),
          ),

          // ---- Header : back (si i>0) + "Passer" ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 20, top: 20),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    if (_index > 0)
                      _CircleButton(icon: Icons.arrow_back, onTap: _prev)
                    else
                      const SizedBox(width: 40),
                    const Spacer(),
                    TextButton(
                      onPressed: _goHome,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xE6FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---- Contenu bas : titre, texte, dots, CTA ----
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(_index),
                        children: [
                          Text(
                            _slidesData[_index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              _slidesData[_index].text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: Colors.white.withOpacity(0.72),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Dots (width 22px actif / 6px inactif, comme .dot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slidesData.length; i++)
                          GestureDetector(
                            onTap: () => _go(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: const Cubic(0.2, 0.8, 0.2, 1),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: i == _index ? 22 : 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // CTA conditionnels (notLast vs isLast)
                    if (!_isLast) ...[
                      _PrimaryButton(label: 'Suivant', onPressed: _next),
                      const SizedBox(height: 63), // <span class="sp1">
                    ] else ...[
                      _PrimaryButton(
                        label: 'Créer un compte',
                        onPressed: _goHome,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _goHome,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.28),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "J'ai déjà un compte",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goHome,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Continuer sans compte',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Une slide : image positionnée (top/h%), overlay dégradé, Ken Burns 12s
// ---------------------------------------------------------------------------
class _SlideView extends StatefulWidget {
  final _SlideData data;
  final double screenHeight;
  final bool visible;

  const _SlideView({
    required this.data,
    required this.screenHeight,
    required this.visible,
  });

  @override
  State<_SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<_SlideView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kb;

  @override
  void initState() {
    super.initState();
    // @keyframes kb_d2 : scale(1.02)→scale(1.1) sur 12s, alternate
    _kb = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery n'est pas fiable dans initState — on l'utilise ici.
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _kb.stop();
      _kb.value = 0.5; // position intermédiaire fixe
    } else if (!_kb.isAnimating) {
      _kb.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _kb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final imgHeight = widget.screenHeight * d.heightFactor;
    final imgTop = widget.screenHeight * d.topFraction;

    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.ease,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image positionnée comme le proto (top %, h %, object-position)
            Positioned(
              left: 0,
              right: 0,
              top: imgTop,
              height: imgHeight,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _kb,
                  builder: (_, child) {
                    // scale 1.02 → 1.10, transform-origin 50% 40%
                    final scale = 1.02 + (0.08 * _kb.value);
                    return Transform(
                      alignment: const Alignment(0, -0.2),
                      transform: Matrix4.identity()..scale(scale),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    d.image,
                    fit: BoxFit.cover,
                    alignment: d.objectPosition,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
            // Overlay dégradé (identique au proto)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B0103),
                    Color(0x750B0103),
                    Color(0x000B0103),
                    Color(0xA383001B),
                    Color(0xD483001B),
                  ],
                  stops: [0, 0.16, 0.5, 0.70, 0.88],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Boutons réutilisables
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFA8161F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}