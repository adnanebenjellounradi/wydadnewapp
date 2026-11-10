import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
// MODÈLES (inchangés)
// ═══════════════════════════════════════════════════════════

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
  });
}

class QuizWinner {
  final int rank;
  final String rewardDescription;
  final String participantName;
  final int score;

  QuizWinner({
    required this.rank,
    required this.rewardDescription,
    required this.participantName,
    required this.score,
  });

  factory QuizWinner.fromJson(Map<String, dynamic> json) {
    return QuizWinner(
      rank: json['rank'],
      rewardDescription: json['reward']['description'],
      participantName: json['participant']['name'],
      score: json['participant']['score'],
    );
  }
}

class QuizReward {
  final int id;
  final int rank;
  final String description;

  QuizReward({
    required this.id,
    required this.rank,
    required this.description,
  });

  factory QuizReward.fromJson(Map<String, dynamic> json) {
    return QuizReward(
      id: json['id'],
      rank: json['rank'],
      description: json['description'],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SERVICES API (inchangés)
// ═══════════════════════════════════════════════════════════

class QuizApiService {
  static const String baseUrl = 'https://quizzbackoff.ma/api/public';

  Future<Map<String, dynamic>?> fetchOrganisationQuiz(int organisationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organisation/1/quizzs'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  List<dynamic> getValidQuizzesForToday(Map<String, dynamic>? apiResponse) {
    if (apiResponse == null || !apiResponse['success']) return [];
    final now = DateTime.now();
    final quizzes = apiResponse['quizzes'] as List;
    return quizzes.where((quiz) {
      if (quiz['dateMinAllowed'] == null || quiz['dateMaxAllowed'] == null) {
        return false;
      }
      try {
        final dateMin = DateTime.parse(quiz['dateMinAllowed']);
        final dateMax = DateTime.parse(quiz['dateMaxAllowed']);
        return now.isAfter(dateMin) && now.isBefore(dateMax);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}

class ParticipationService {
  static const String baseUrl = 'https://quizzbackoff.ma/api';

  static Future<Map<String, dynamic>> submitParticipation({
    required int quizId,
    required String email,
    required String name,
    required String participantId,
    required String phone,
    required int score,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://quizzbackoff.ma/api/public/quiz/$quizId/participate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'participantId': participantId,
          'phone': phone,
          'score': score.toString(),
        }),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to submit participation');
    } catch (e) {
      debugPrint('Erreur dans ParticipationService: $e');
      rethrow;
    }
  }

  static Future<bool> hasParticipated({
    required int quizId,
    required String email,
    String? token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/$quizId/participants'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final participants = data['participants'] as List;
        return participants.any((p) => p['email'] == email);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE PRINCIPALE
// ═══════════════════════════════════════════════════════════

class WydadQuizPage extends StatefulWidget {
  final String? token;
  final String? currentOrganizationId;
  final String? userName;

  const WydadQuizPage({
    Key? key,
    this.token,
    this.currentOrganizationId,
    this.userName,
  }) : super(key: key);

  @override
  State<WydadQuizPage> createState() => _WydadQuizPageState();
}

class _WydadQuizPageState extends State<WydadQuizPage> {
  // ─── STATE (logique existante) ───
  int _currentScreen = 0;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _selectedAnswerIndex = -1;
  bool _showResult = false;
  bool _isCorrect = false;
  late List<QuizQuestion> _questions;
  Timer? _questionTimer;
  int _timeLeft = 20;

  final QuizApiService _apiService = QuizApiService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _apiResponse;
  Map<String, dynamic>? _currentQuiz;
  String _organisationName = 'Quiz';
  String _playerName = '';

  List<QuizWinner> _winners = [];
  List<QuizReward> _rewards = [];
  bool _hasWinners = false;
  bool _hasTicketReward = false;

  String _userEmail = '';
  String _userId = '';
  String _userPhone = '';
  bool _participationSubmitted = false;
  bool _isSubmittingParticipation = false;
  bool _hasAlreadyParticipated = false;

  final Color primary = const Color(0xFFA8161F);

  // ─── INIT ───
  @override
  void initState() {
    super.initState();
    _questions = [];
    _loadPlayerName();
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadQuizFromApi();
    });
  }

  @override
  void didUpdateWidget(WydadQuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentOrganizationId != oldWidget.currentOrganizationId) {
      _loadQuizFromApi();
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final firstName = prefs.getString('user_name') ?? '';
      final lastName = prefs.getString('user_last_name') ?? '';
      _playerName = (firstName + ' ' + lastName).trim();
    });
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? '';
      _userId = prefs.getString('user_id') ?? '';
      _userPhone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> _loadQuizFromApi() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orgId = widget.currentOrganizationId != null
          ? int.tryParse(widget.currentOrganizationId!) ?? 1
          : 1;
      final response = await _apiService.fetchOrganisationQuiz(orgId);

      if (response != null) {
        final validQuizzes = _apiService.getValidQuizzesForToday(response);
        setState(() {
          _apiResponse = response;
          _organisationName = response['organisation']['name'] ?? 'Quiz';
          if (validQuizzes.isNotEmpty) {
            _currentQuiz = validQuizzes.first;
            if (_currentQuiz!['rewards'] != null) {
              _rewards = (_currentQuiz!['rewards'] as List)
                  .map((r) => QuizReward.fromJson(r))
                  .toList();
              _hasTicketReward = _rewards.any(
                      (reward) => reward.description.toLowerCase().contains('ticket'));
            }
            _hasWinners = _currentQuiz!['showWinners'] == true &&
                _currentQuiz!['hasWinners'] == true &&
                _currentQuiz!['winners'] != null &&
                (_currentQuiz!['winners'] as List).isNotEmpty;
            if (_hasWinners) {
              _winners = (_currentQuiz!['winners'] as List)
                  .map((w) => QuizWinner.fromJson(w))
                  .toList();
              _currentScreen = 3;
            } else {
              _questions = _convertApiQuizzesToQuestions([_currentQuiz!]);
            }
            _isLoading = false;
            _checkIfAlreadyParticipated();
          } else {
            _isLoading = false;
            _errorMessage = l10n.noQuizAvailableToday;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = l10n.unableToLoadQuizzes;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${l10n.error}: $e';
      });
    }
  }

  Future<void> _checkIfAlreadyParticipated() async {
    if (_userEmail.isEmpty) return;
    try {
      final quizId = _getQuizId();
      final hasParticipated = await ParticipationService.hasParticipated(
        quizId: quizId,
        email: _userEmail,
        token: widget.token,
      );
      setState(() => _hasAlreadyParticipated = hasParticipated);
      if (hasParticipated) _participationSubmitted = true;
    } catch (e) {
      debugPrint('Error checking participation status: $e');
    }
  }

  int _getQuizId() {
    if (_currentQuiz != null) return _currentQuiz!['id'];
    return 1;
  }

  List<QuizQuestion> _convertApiQuizzesToQuestions(List<dynamic> quizzes) {
    List<QuizQuestion> questions = [];
    for (var quiz in quizzes) {
      final quizQuestions = quiz['questions'] as List;
      for (var q in quizQuestions) {
        List<String> options = [];
        options.add(q['correctAnswer']);
        for (var wrong in q['wrongAnswers']) {
          options.add(wrong['answer']);
        }
        options.shuffle();
        int correctIndex = options.indexOf(q['correctAnswer']);
        questions.add(QuizQuestion(
          id: q['id'],
          question: q['question'],
          options: options,
          correctAnswerIndex: correctIndex,
          explanation: 'Bonne réponse : ${q['correctAnswer']}',
          difficulty: (q['points'] / 30).ceil().clamp(1, 3),
        ));
      }
    }
    questions.shuffle();
    if (questions.length > 10) questions = questions.sublist(0, 10);
    return questions;
  }

  void _startQuiz() {
    if (_hasAlreadyParticipated) {
      _showAlreadyParticipatedDialog();
      return;
    }
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = -1;
      _showResult = false;
      _currentScreen = 1;
      _startTimer();
    });
  }

  void _showAlreadyParticipatedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.alreadyParticipated),
        content: Text(l10n.alreadyParticipatedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timeLeft = 20;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _nextQuestion();
        }
      });
    });
  }

  void _answerQuestion(int index) {
    if (_selectedAnswerIndex != -1) return;
    _questionTimer?.cancel();
    bool correct = (index == _questions[_currentQuestionIndex].correctAnswerIndex);
    setState(() {
      _selectedAnswerIndex = index;
      _showResult = true;
      _isCorrect = correct;
      if (correct) _score++;
    });
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _showResult = false;
        _isCorrect = false;
        _startTimer();
      });
    } else {
      _questionTimer?.cancel();
      _submitParticipation();
    }
  }

  Future<void> _submitParticipation() async {
    final l10n = AppLocalizations.of(context)!;
    if (_participationSubmitted || _hasAlreadyParticipated) {
      setState(() => _currentScreen = 2);
      return;
    }
    setState(() => _isSubmittingParticipation = true);

    try {
      if (_userEmail.isEmpty || _playerName.isEmpty || _userId.isEmpty) {
        _showInfoMissingDialog();
        setState(() {
          _currentScreen = 2;
          _isSubmittingParticipation = false;
        });
        return;
      }
      final quizId = _getQuizId();
      await ParticipationService.submitParticipation(
        quizId: quizId,
        email: _userEmail,
        name: _playerName,
        participantId: _userId,
        score: _score,
        phone: _userPhone,
        token: widget.token,
      );
      setState(() {
        _participationSubmitted = true;
        _hasAlreadyParticipated = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quiz_participated_$quizId', true);
      _showParticipationSuccess();
    } catch (e) {
      if (e.toString().contains('already participated')) {
        setState(() {
          _hasAlreadyParticipated = true;
          _participationSubmitted = false;
        });
        _showAlreadyParticipatedDialog();
      } else {
        _showParticipationError();
        setState(() => _participationSubmitted = false);
      }
    } finally {
      setState(() {
        _isSubmittingParticipation = false;
        _currentScreen = 2;
      });
    }
  }

  void _showInfoMissingDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.missingInformation),
        content: Text(l10n.loginToSaveScore),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showParticipationSuccess() {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${l10n.yourScoreOf} $_score/${_questions.length} ${l10n.hasBeenSaved}!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showParticipationError() {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.scoreNotSaved),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _getResultMessage(int percentage) {
    final l10n = AppLocalizations.of(context)!;
    if (percentage >= 90) return l10n.expert;
    if (percentage >= 70) return l10n.veryGood;
    if (percentage >= 50) return l10n.notBad;
    if (percentage >= 30) return l10n.studyMore;
    return l10n.keepGoing;
  }

  String _getRankText(int rank) {
    final l10n = AppLocalizations.of(context)!;
    switch (rank) {
      case 1: return l10n.first;
      case 2: return l10n.second;
      case 3: return l10n.third;
      case 4: return l10n.fourth;
      case 5: return l10n.fifth;
      default: return '$rank${l10n.th}';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primary),
                const SizedBox(height: 20),
                Text(
                  'Chargement du quiz...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _glassBackButton(() => Navigator.pop(context)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: primary),
                          const SizedBox(height: 20),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Inter',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadQuizFromApi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                            ),
                            child: Text(
                              l10n.retry,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        child: Stack(
          children: [
            // Glow radial
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
              bottom: false,
              child: _currentScreen == 3
                  ? _buildWinnersDesign()
                  : _currentScreen == 0
                  ? _buildHomeDesign()
                  : _currentScreen == 1
                  ? _buildQuizDesign()
                  : _buildResultsDesign(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBackButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉCRAN ACCUEIL (design HTML)
  // ═══════════════════════════════════════════════════════════
  Widget _buildHomeDesign() {
    final l10n = AppLocalizations.of(context)!;
    final isSponsored = _currentQuiz != null && _currentQuiz!['isSponsored'] == true;
    final sponsorName = _currentQuiz?['sponsor'] ?? l10n.sponsor;
    final bannerPath = _currentQuiz?['bannerImage'];
    final String? bannerImage = bannerPath != null ? 'https://quizzbackoff.ma$bannerPath' : null;
    final permalinkBanner = _currentQuiz?['permalinkBanner'];

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              _glassBackButton(() => Navigator.pop(context)),
              const Spacer(),
              Text(
                'Question ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSponsored && bannerImage != null)
                  GestureDetector(
                    onTap: permalinkBanner != null ? () => _launchURL(permalinkBanner) : null,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          bannerImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: primary.withOpacity(0.1),
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white38),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Carte principale gradient
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -40,
                          bottom: -60,
                          child: Text(
                            '?',
                            style: TextStyle(
                              fontSize: 180,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              color: Colors.white.withOpacity(0.08),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuiz?['title'] ?? 'Quiz du jour',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentQuiz?['description'] ??
                                    '${_questions.length} questions sur le club',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.86),
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer,
                                            color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_questions.length} questions',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSponsored) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF40000),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        sponsorName,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Récompenses
                if (_rewards.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.07),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard,
                                color: Color(0xFFF5CD52), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Récompenses',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._rewards.map((reward) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: reward.rank == 1
                                      ? const Color(0xFFFFD700)
                                      : reward.rank == 2
                                      ? const Color(0xFFC0C0C0)
                                      : const Color(0xFFCD7F32),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#${reward.rank}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reward.description,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Stat cards
                Row(
                  children: [
                    _buildStatCard('${_questions.length}', 'Questions'),
                    const SizedBox(width: 8),
                    _buildStatCard('20s', 'Par question'),
                    const SizedBox(width: 8),
                    _buildStatCard(
                        '${_questions.length * 20 ~/ 60}m', 'Durée'),
                  ],
                ),

                const SizedBox(height: 24),

                // Bouton démarrer
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _hasAlreadyParticipated
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          l10n.youHaveAlreadyParticipated,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          l10n.startQuiz,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉCRAN QUIZ (design HTML F3)
  // ═══════════════════════════════════════════════════════════
  Widget _buildQuizDesign() {
    final l10n = AppLocalizations.of(context)!;
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              _glassBackButton(() => Navigator.pop(context)),
              const Spacer(),
              Text(
                'Question ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(Icons.timer,
                        color: _timeLeft < 5 ? Colors.red : Colors.white,
                        size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '0:$_timeLeft',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _timeLeft < 5 ? Colors.red : Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Barre de progression
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: List.generate(_questions.length, (i) {
              Color color;
              if (i < _currentQuestionIndex) {
                color = const Color(0xFFF5CD52);
              } else if (i == _currentQuestionIndex) {
                color = Colors.white;
              } else {
                color = Colors.white.withOpacity(0.16);
              }
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                      right: i == _questions.length - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: color,
                  ),
                ),
              );
            }),
          ),
        ),

        // Carte question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 150),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -40,
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 160,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            color: Colors.white.withOpacity(0.08),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(question.options.length, (index) {
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == question.correctAnswerIndex;

                  Color bg;
                  Color border;
                  Color? markColor;
                  String? mark;

                  if (!_showResult) {
                    bg = Colors.white.withOpacity(0.07);
                    border = Colors.white.withOpacity(0.12);
                  } else if (isCorrect) {
                    bg = const Color(0xFFF5CD52).withOpacity(0.14);
                    border = const Color(0xFFF5CD52);
                    markColor = const Color(0xFFF5CD52);
                    mark = 'Bonne réponse';
                  } else if (isSelected) {
                    bg = const Color(0xFFFF8A8A).withOpacity(0.12);
                    border = const Color(0xFFFF8A8A);
                    markColor = const Color(0xFFFF8A8A);
                    mark = 'Votre réponse';
                  } else {
                    bg = Colors.white.withOpacity(0.07);
                    border = Colors.white.withOpacity(0.12);
                  }

                  return GestureDetector(
                    onTap: _selectedAnswerIndex == -1
                        ? () => _answerQuestion(index)
                        : null,
                    child: Container(
                      height: 58,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: bg,
                        border: Border.all(
                            color: border,
                            width: (_showResult && (isCorrect || isSelected))
                                ? 1.5
                                : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Colors.white.withOpacity(0.10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (mark != null)
                            Text(
                              mark,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: markColor,
                                fontFamily: 'Inter',
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                if (_showResult) ...[
                  Text(
                    _isCorrect ? l10n.correctAnswer : l10n.wrongAnswer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF8A8A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ] else ...[
                  Text(
                    'Répondez vite : plus vous êtes rapide, plus vous gagnez de points.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ÉCRAN RÉSULTATS (design HTML F4)
  // ═══════════════════════════════════════════════════════════
  Widget _buildResultsDesign() {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_score / _questions.length * 100).round();
    final conicAngle = (_score / _questions.length) * 360;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          const Spacer(),

          // Cercle avec score
          SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: _ConicProgressPainter(
                percent: _score / _questions.length,
                activeColor: const Color(0xFFF5CD52),
                inactiveColor: Colors.white.withOpacity(0.12),
              ),
              child: Center(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF07060F),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_score/${_questions.length}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'bonnes réponses',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          Text(
            _getResultMessage(percentage),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Badge points
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFFC97A).withOpacity(0.14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFC97A), size: 14),
                const SizedBox(width: 6),
                Text(
                  '+${_score * 30} points',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFC97A),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Carte tirage
          if (_hasTicketReward)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD11A2A), Color(0xFFA8161F), Color(0xFF6E0B12)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFB0141F), Color(0xFF860D16)],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.card_giftcard,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vous participez au tirage',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _rewards.isNotEmpty
                              ? _rewards.first.description
                              : '2 billets pour le prochain match',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.86),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Bouton retour
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Retour à l\'accueil',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _participationSubmitted
                ? 'Score enregistré · ${l10n.yourScoreOf} $_score/${_questions.length}'
                : 'Nouveau quiz demain à 12:00',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WINNERS (design minimal conservé)
  // ═══════════════════════════════════════════════════════════
  Widget _buildWinnersDesign() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _glassBackButton(() => Navigator.pop(context)),
              const Spacer(),
              Text(
                l10n.winnersList,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 20),
          if (_hasAlreadyParticipated)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.youParticipatedInQuiz,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF4CAF50),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ..._winners.map((winner) {
            final rankColor = winner.rank == 1
                ? const Color(0xFFFFD700)
                : winner.rank == 2
                ? const Color(0xFFC0C0C0)
                : winner.rank == 3
                ? const Color(0xFFCD7F32)
                : const Color(0xFF2196F3);
            final emoji = winner.rank == 1
                ? '🥇'
                : winner.rank == 2
                ? '🥈'
                : winner.rank == 3
                ? '🥉'
                : '🏅';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rankColor.withOpacity(0.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner.participantName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          winner.rewardDescription,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: rankColor.withOpacity(0.2),
                    ),
                    child: Text(
                      '#${winner.rank}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: rankColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// PAINTER pour le cercle de progression conique
// ═══════════════════════════════════════════════════════════
class _ConicProgressPainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color inactiveColor;

  _ConicProgressPainter({
    required this.percent,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 13.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Inactif
    final paintBg = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paintBg);

    // Actif (arc)
    final paintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159265 * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweepAngle,
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant _ConicProgressPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}