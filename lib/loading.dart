import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final VideoPlayerController _controller;
  Timer? _navTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videolancement.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
        // Durée du splash, comme dans le proto (3900 ms)
        _navTimer = Timer(const Duration(milliseconds: 3900), _goNext);
      }).catchError((e) {
        // Si la vidéo échoue (émulateur, codec…), on continue quand même
        debugPrint('Video init failed: $e');
        _navTimer = Timer(const Duration(milliseconds: 3900), _goNext);
      });
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    const organizationId = 20;

    if (!mounted) return;

    if (token.isNotEmpty) {
      // Déjà connecté → accueil
      Navigator.of(context).pushReplacementNamed(
        '/acceuil',
        arguments: {
          'token': token,
          'organizationId': 20,
        },
      );
    } else {
      // Pas connecté → présentation
      Navigator.of(context).pushReplacementNamed('/presentation');
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120104),
      body: GestureDetector(
        // Tap pour sauter le splash (comme le <a> du proto)
        onTap: _goNext,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: _controller.value.isInitialized
              ? FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}