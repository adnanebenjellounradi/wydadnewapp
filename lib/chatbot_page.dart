import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'l10n/app_localizations.dart';

class ChatbotPage extends StatefulWidget {
  final String? organizationId;

  const ChatbotPage({
    Key? key,
    this.organizationId,
  }) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  // ═══════════════════════════════════════════════════════
  // CONFIG
  // ═══════════════════════════════════════════════════════
  static const String BASE_URL = 'https://quizzbackoff.ma';
  static const String UNIQUE_ID = 'dsqqqqqlkkkkljlkwwwwwww';
  static const String PUSHER_KEY = '612ce5ee17d548691833';
  static const String PUSHER_CLUSTER = 'eu';

  final Color primary = const Color(0xFFA8161F);
  final String _conversationId = const Uuid().v4();

  // Messages
  final List<Map<String, dynamic>> _messages = [];

  // État du chatbot
  String _currentNodeId = '';
  bool _isEnd = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ Infos utilisateur
  Map<String, String> _userInfo = {};

  // Live chat
  bool _liveMode = false;
  PusherChannelsFlutter? _pusher;
  final TextEditingController _liveController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ✅ Typing simulation
  bool _isTyping = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ✅ FORCER L'ID À 5 ICI (pour les tests)
  int get _orgId => 5;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadUserInfo();
    await _loadStep(nodeId: '', answer: null);
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userInfo = {
        'id': prefs.getString('user_id') ?? 'Inconnu',
        'email': prefs.getString('user_email') ?? 'Inconnu',
        'phone': prefs.getString('phone') ?? 'Inconnu',
        'name': '${prefs.getString('user_name') ?? ''} ${prefs.getString('user_last_name') ?? ''}'.trim(),
      };
      if (_userInfo['name']!.isEmpty) {
        _userInfo['name'] = 'Client';
      }
    });
  }

  @override
  void dispose() {
    _pusher?.disconnect();
    _liveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Vérification des horaires (9h - 19h)
  bool _isWithinBusinessHours() {
    final now = DateTime.now();
    return now.hour >= 9 && now.hour < 22;
  }

  // ═══════════════════════════════════════════════════════
  // APPEL API /api/chat/step
  // ═══════════════════════════════════════════════════════
  Future<void> _loadStep({required String nodeId, String? answer}) async {
    setState(() {
      _isLoading = true;
      _isTyping = true;
      if (answer != null) {
        _messages.add({'role': 'user', 'content': answer});
      }
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/chat/step'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileApp': true,
          'unique_id': UNIQUE_ID,
          'organisationId': _orgId,
          'nodeId': nodeId,
          'answer': answer,
          'conversationId': _conversationId,
          'userInfo': _userInfo,
        }),
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Service momentanément indisponible.';
          _isLoading = false;
          _isTyping = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // ✅ Simulation humaine
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _currentNodeId = data['nodeId'] ?? '';
        _isEnd = data['end'] == true;
        _isLoading = false;
        _isTyping = false;
        _errorMessage = null;

        String question = data['question'] ?? '';
        List<Map<String, dynamic>> buttons = List<Map<String, dynamic>>.from(data['buttons'] ?? []);

        if (question.isNotEmpty) {
          _messages.add({
            'role': 'bot',
            'content': question,
            'buttons': buttons,
          });
        }
      });
      _scrollToBottom();

      if (data['escalate'] == true) {
        // ✅ Vérification des horaires avant de lancer le live chat
        if (_isWithinBusinessHours()) {
          await _startLiveChat();
        } else {
          _showOutsideHoursModal(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion. Vérifiez votre réseau.';
        _isLoading = false;
        _isTyping = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════
  // LIVE CHAT — Pusher
  // ═══════════════════════════════════════════════════════
  Future<void> _startLiveChat() async {
    if (_liveMode) return;
    setState(() {
      _liveMode = true;
      _isTyping = true;
    });

    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher!.init(
      apiKey: PUSHER_KEY,
      cluster: PUSHER_CLUSTER,
      onAuthorizer: (channelName, socketId, options) async {
        final res = await http.post(
          Uri.parse('$BASE_URL/api/pusher/auth'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'socket_id=$socketId'
              '&channel_name=$channelName'
              '&unique_id=$UNIQUE_ID'
              '&organisation_id=$_orgId',
        );
        return jsonDecode(res.body) as Map<String, dynamic>;
      },
      onEvent: (event) {
        if (event.eventName == 'new_message') {
          final payload = jsonDecode(event.data);
          if (payload['from'] == 'agent') {
            setState(() {
              _messages.add({
                'role': 'agent',
                'content': payload['content']?.toString() ?? '',
              });
            });
            _scrollToBottom();
          }
        }
      },
      onError: (message, code, error) {
        print('❌ Pusher Error: $message');
      },
    );

    await _pusher!.connect();
    await _pusher!.subscribe(channelName: 'private-org-$_orgId-conv-$_conversationId');

    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isTyping = false);
  }

  Future<void> _sendLiveMessage() async {
    final text = _liveController.text.trim();
    if (text.isEmpty) return;
    _liveController.clear();

    setState(() => _messages.add({'role': 'user', 'content': text}));
    _scrollToBottom();

    try {
      await http.post(
        Uri.parse('$BASE_URL/api/chat/live/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'unique_id': UNIQUE_ID,
          'organisationId': _orgId,
          'conversationId': _conversationId,
          'message': text,
        }),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Impossible d\'envoyer le message.');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // MODAL HORS HORAIRES
  // ═══════════════════════════════════════════════════════
  void _showOutsideHoursModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (BuildContext context) {
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.access_time, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Conseiller indisponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nos conseillers sont disponibles de 9h à 19h. Veuillez réessayer pendant les heures d\'ouverture.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD11A2A), Color(0xFFA8161F)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Fermer',
                          style: TextStyle(
                            fontFamily: 'urbanist',
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

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final discussionHeight = screenHeight * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(
              height: discussionHeight - 150,
              child: _buildMessages(),
            ),
            if (_liveMode)
              Container(
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildLiveInput(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E0409).withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: _liveMode ? const Color(0xFFF5CD52) : const Color(0xFFE41E26),
            child: Icon(
              _liveMode ? Icons.headset_mic : Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _liveMode ? 'Conseiller' : 'Assistant',
                  style: const TextStyle(
                    fontFamily: 'urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (_liveMode)
                  Text(
                    'En ligne',
                    style: TextStyle(
                      fontFamily: 'urbanist',
                      fontSize: 11,
                      color: Colors.greenAccent.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final msg = _messages[index];
        final role = msg['role'];
        final isUser = role == 'user';
        final isAgent = role == 'agent';
        final buttons = msg['buttons'] as List<Map<String, dynamic>>?;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: isAgent ? const Color(0xFFF5CD52) : const Color(0xFFE41E26),
                    child: Icon(
                      isAgent ? Icons.headset_mic : Icons.smart_toy,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        gradient: isUser ? const LinearGradient(colors: [Color(0xFFD11A2A), Color(0xFFA8161F)]) : null,
                        color: isUser ? null : Colors.white.withOpacity(0.08),
                        border: isUser ? null : Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: Text(
                        msg['content'] ?? '',
                        style: TextStyle(
                          fontFamily: 'urbanist',
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.white,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!isUser && buttons != null && buttons.isNotEmpty && !_isEnd)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: buttons.map((button) {
                            final label = button['label']?.toString() ?? '';
                            return GestureDetector(
                              onTap: () => _loadStep(nodeId: _currentNodeId, answer: label),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.08),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'urbanist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFF5CD52),
              child: Icon(Icons.headset_mic, color: Colors.white, size: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: const TypingAnimation(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF170205).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _liveController,
              style: const TextStyle(fontFamily: 'urbanist', fontSize: 14, color: Colors.white),
              cursorColor: const Color(0xFFF5CD52),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendLiveMessage(),
              decoration: InputDecoration(
                hintText: 'Écrivez un message...',
                hintStyle: TextStyle(fontFamily: 'urbanist', fontSize: 13, color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.14))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.14))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendLiveMessage,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFFD11A2A), Color(0xFFA8161F)]),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE5484D).withOpacity(0.15),
        border: Border.all(color: const Color(0xFFE5484D).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE5484D), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(fontFamily: 'urbanist', fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Animation des 3 points
class TypingAnimation extends StatefulWidget {
  const TypingAnimation({Key? key}) : super(key: key);

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = 0.3 + (value * 0.7);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}