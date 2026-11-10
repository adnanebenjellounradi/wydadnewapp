import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show ImageFilter;
import 'l10n/app_localizations.dart';

class PlayerRatingPage extends StatefulWidget {
  final String? token;
  final String? eventId;
  final String? organizationId;
  final Map<String, dynamic>? eventData;

  const PlayerRatingPage({
    Key? key,
    this.token,
    this.eventId,
    this.organizationId,
    this.eventData,
  }) : super(key: key);

  @override
  _PlayerRatingPageState createState() => _PlayerRatingPageState();
}

class _PlayerRatingPageState extends State<PlayerRatingPage> with TickerProviderStateMixin {
  List<dynamic> players = [];
  List<dynamic> substitutions = [];
  bool isLoading = true;
  String? votedPlayerId;
  bool hasVoteBeenSubmitted = false;
  Map<String, dynamic> playerPositions = {};
  Map<String, dynamic>? eventDetails;
  bool isEventFinished = false;
  Map<String, dynamic>? manOfTheMatch;

  final String baseUrl = 'https://ticketing.ma/api';

  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _headerSlideAnimation;

  final Color primaryRed = const Color(0xFFE41E26);
  final Color darkRed = const Color(0xFFB71C1C);
  final Color pitchGreen = const Color(0xFF1B4D3E);
  final Color pitchLightGreen = const Color(0xFF2E7D5E);

  final Color goldColor = const Color(0xFFFFD700);
  final Color silverColor = const Color(0xFFC0C0C0);
  final Color bronzeColor = const Color(0xFFCD7F32);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Appeler _loadEventData() ici après que les dépendances sont chargées
    // Utiliser Future.microtask pour éviter les problèmes avec le build
    Future.microtask(() {
      if (mounted) {
        _loadEventData();
      }
    });
  }
  Future<void> _loadEventData() async {
    setState(() => isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      if (widget.eventId != null) {
        await _fetchEventDetails();
        await _fetchEventPlayers();

        _checkIfEventFinished();

        if (!isEventFinished) {
          await _checkIfVoteSubmitted();
          if (!hasVoteBeenSubmitted) {
            await _loadVotedPlayer();
          }
        } else {
          _findManOfTheMatch();
        }

        _fabAnimationController.forward();
      }
    } catch (e) {
      _showSnackBar("${l10n.errorLoadingData}: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _checkIfEventFinished() {
    final l10n = AppLocalizations.of(context)!;
    if (eventDetails == null) {
      setState(() {
        isEventFinished = false;
      });
      return;
    }

    bool isFinishedByTime = false;

    if (eventDetails!.containsKey('date') && eventDetails!['date'] != null) {
      try {
        String startTimeStr = eventDetails!['date'];
        DateTime startTime = DateTime.parse(startTimeStr);
        DateTime now = DateTime.now();

        Duration difference = now.difference(startTime);
        int minutesSinceStart = difference.inMinutes;
        isFinishedByTime = minutesSinceStart >= 135;

      } catch (e) {
        print('Error parsing start time: $e');
        isFinishedByTime = false;
      }
    } else {
      print('No start_time found in event details');
    }

    setState(() {
      isEventFinished = isFinishedByTime;
    });

    if (isEventFinished) {
      _findManOfTheMatch();
    }
  }

  void _findManOfTheMatch() {
    if (players.isEmpty) {
      setState(() {
        manOfTheMatch = null;
      });
      return;
    }

    final sorted = List<Map<String, dynamic>>.from(players);
    sorted.sort((a, b) {
      final aVotes = (a["number_of_votes"] as num?)?.toInt() ?? 0;
      final bVotes = (b["number_of_votes"] as num?)?.toInt() ?? 0;
      return bVotes.compareTo(aVotes);
    });

    setState(() {
      manOfTheMatch = sorted.isNotEmpty ? sorted.first : null;
    });
  }

  Future<void> _fetchEventDetails() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final url = '$baseUrl/customer/events/${widget.eventId}';
      final headers = {
        'Content-Type': 'application/json',
        if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
      };

      final queryParams = <String, String>{};
      if (widget.organizationId != null) {
        queryParams['organization_id'] = widget.organizationId!;
      }

      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            eventDetails = jsonResponse['data'];
          });
        }
      } else {
        throw Exception(l10n.failedToLoadEventDetails);
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
  }

  Future<void> _fetchEventPlayers() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final url = '$baseUrl/customer/events/${widget.eventId}/players';
      final headers = {
        'Content-Type': 'application/json',
        if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
      };
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> allPlayers = jsonResponse['data'];

          setState(() {
            players = allPlayers.where((p) => p["is_titulaire"] == 1).toList();
            substitutions = allPlayers.where((p) => p["is_titulaire"] == 0).toList();

            _assignPlayersByPosition();
          });
        }
      } else {
        throw Exception(l10n.failedToLoadPlayers);
      }
    } catch (e) {
      print('Error fetching players: $e');
      setState(() {
        players = [];
        substitutions = [];
      });
    }
  }

  Future<void> _submitVote(String playerId) async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.token == null) {
      _showSnackBar(l10n.loginRequiredToVote, isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = '$baseUrl/customer/events/player/vote';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      };

      final Map<String, dynamic> bodyData = {
        'event_id': int.parse(widget.eventId!),
        'player_id': int.parse(playerId),
        'rating': 5,
      };

      // ✅ Supprimer le commentaire du body
      // if (comment != null && comment.isNotEmpty) {
      //   bodyData['comment'] = comment;
      // }

      final body = json.encode(bodyData);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            votedPlayerId = playerId;
          });

          await _markVoteAsSubmitted();
          await _saveVotedPlayer();
          await _fetchEventPlayers();

          _showSuccessDialog();
        }
      } else {
        throw Exception(l10n.failedToSubmitVote);
      }
    } catch (e) {
      _showSnackBar("${l10n.errorSubmittingVote}: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIfVoteSubmitted() async {
    if (widget.eventId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final voteSubmitted = prefs.getBool('vote_submitted_${widget.eventId}') ?? false;

    setState(() {
      hasVoteBeenSubmitted = voteSubmitted;
    });
  }

  Future<void> _markVoteAsSubmitted() async {
    if (widget.eventId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vote_submitted_${widget.eventId}', true);

    setState(() {
      hasVoteBeenSubmitted = true;
    });
  }

  Future<void> _loadVotedPlayer() async {
    if (widget.eventId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final savedVote = prefs.getString('votedPlayerId_${widget.eventId}');

    setState(() {
      votedPlayerId = savedVote;
    });
  }

  Future<void> _saveVotedPlayer() async {
    if (widget.eventId == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (votedPlayerId != null) {
      await prefs.setString('votedPlayerId_${widget.eventId}', votedPlayerId!);
    } else {
      await prefs.remove('votedPlayerId_${widget.eventId}');
    }
  }

  void _assignPlayersByPosition() {
    playerPositions.clear();

    List<Map<String, dynamic>> titulaires = [];
    for (var player in players) {
      if (player["is_titulaire"] == 1) {
        titulaires.add(Map<String, dynamic>.from(player));
      }
    }

    List<Map<String, dynamic>> cbs = [];
    List<Map<String, dynamic>> autres = [];

    for (var player in titulaires) {
      if (player["specific_position"] == "CB") {
        cbs.add(player);
      } else {
        autres.add(player);
      }
    }

    for (int i = 0; i < cbs.length; i++) {
      if (i == 0) {
        _assignPosition(cbs[i], 'CB1', const Offset(0.4, 0.8));
      } else if (i == 1) {
        _assignPosition(cbs[i], 'CB2', const Offset(0.63, 0.8));
      }
    }

    for (var player in autres) {
      String specPos = player["specific_position"] as String;

      switch(specPos) {
        case 'GK':
          _assignPosition(player, 'GK', const Offset(0.5, 1.03));
          break;
        case 'LB':
          _assignPosition(player, 'LB', const Offset(0.15, 0.75));
          break;
        case 'RB':
          _assignPosition(player, 'RB', const Offset(0.87, 0.75));
          break;
        case 'CDM':
          _assignPosition(player, 'CDM', const Offset(0.5, 0.5));
          break;
        case 'LM':
          _assignPosition(player, 'LCM', const Offset(0.25, 0.5));
          break;
        case 'RM':
          _assignPosition(player, 'RCM', const Offset(0.75, 0.5));
          break;
        case 'LW':
          _assignPosition(player, 'LW', const Offset(0.2, 0.2));
          break;
        case 'ST':
          _assignPosition(player, 'ST', const Offset(0.5, 0.2));
          break;
        case 'RW':
          _assignPosition(player, 'RW', const Offset(0.8, 0.2));
          break;
        default:
          print("⚠️ Position not recognized: $specPos for ${player['name']}");
      }
    }
  }

  void _assignPosition(Map<String, dynamic> player, String positionKey, Offset position) {
    playerPositions[positionKey] = {
      'player': player,
      'position': position,
    };
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get topVotedPlayers {
    final sorted = List<Map<String, dynamic>>.from(players);
    sorted.sort((a, b) {
      final aVotes = (a["number_of_votes"] as num?)?.toInt() ?? 0;
      final bVotes = (b["number_of_votes"] as num?)?.toInt() ?? 0;
      return bVotes.compareTo(aVotes);
    });
    return sorted.take(3).toList();
  }

  String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}. ${parts.last}";
    }
    return fullName;
  }
  Future<void> _voteForPlayer(String playerId, String playerName) async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.token == null) {
      _showSnackBar(l10n.loginRequiredToVote, isError: true);
      return;
    }

    if (hasVoteBeenSubmitted) {
      _showSnackBar(l10n.alreadyVotedForEvent, isError: true);
      return;
    }

    if (votedPlayerId != null) {
      _showSnackBar(l10n.alreadySelectedPlayer, isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A2E24),
                const Color(0xFF0A1F1A),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: primaryRed.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryRed.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête avec icône
              Container(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryRed,
                            primaryRed.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryRed.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.thumb_up_alt_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.confirmVote,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contenu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Nom du joueur
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryRed.withOpacity(0.2),
                            primaryRed.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryRed.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Message de confirmation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryRed.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: primaryRed,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.voteConfirmationMessage,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontFamily: 'Urbanist',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Badge d'avertissement
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.irreversibleAction,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Boutons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          l10n.confirm,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _submitVote(playerId);
    }
  }



  bool _isPlayerVoted(String playerId) {
    return votedPlayerId == playerId;
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    final votedPlayer = players.firstWhere(
          (p) => p["id"].toString() == votedPlayerId,
      orElse: () => {"name": l10n.unknown},
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 50,
                      color: primaryRed,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.thankYouForVote,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${l10n.youVotedFor} ${votedPlayer['name']}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? darkRed : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPlayerDetailsModal(Map<String, dynamic> player) {
    final l10n = AppLocalizations.of(context)!;
    final playerId = player["id"].toString();
    final isVoted = _isPlayerVoted(playerId);
    final canVote = !hasVoteBeenSubmitted && votedPlayerId == null && widget.token != null && !isEventFinished;
    final numberOfVotes = (player["number_of_votes"] as num?)?.toInt() ?? 0;
    final userVote = player["user_vote"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2E24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryRed, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: primaryRed.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: player['image'] != null
                    ? Image.network(
                  player['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryRed,
                      child: Center(
                        child: Text(
                          player['number']?.toString() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: primaryRed,
                  child: Center(
                    child: Text(
                      player['number']?.toString() ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              player['name'] ?? l10n.unknownPlayer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryRed.withOpacity(0.5)),
                  ),
                  child: Text(
                    player['position'] ?? '',
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${l10n.number}${player['number'] ?? '?'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailItem(
                  icon: Icons.flag_outlined,
                  label: l10n.nationality,
                  value: player['nationality'] ?? l10n.notAvailable,
                ),
                _buildDetailItem(
                  icon: Icons.cake_outlined,
                  label: l10n.age,
                  value: '${player['age'] ?? l10n.notAvailable} ${l10n.yearsOld}',
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primaryRed.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${l10n.votes}: $numberOfVotes",
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),

            if (!isEventFinished) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canVote
                      ? () {
                    Navigator.pop(context);
                    _voteForPlayer(playerId, player['name']);
                  }
                      : null,
                  icon: const Icon(Icons.thumb_up),
                  label: Text(
                    isVoted ? l10n.votedForPlayer : l10n.vote,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVoted
                        ? Colors.green.shade700
                        : (canVote ? primaryRed : Colors.grey.shade500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            if (widget.token == null && !isEventFinished) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.loginToVote,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isEventFinished) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.eventFinishedVotesClosed,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (hasVoteBeenSubmitted && !isEventFinished) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryRed.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.alreadyVotedForEventMessage,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!hasVoteBeenSubmitted && votedPlayerId != null && votedPlayerId != playerId && !isEventFinished) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onlyOneVoteAllowed,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.close,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showSubstitutionsList() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1A2E24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.substitutes,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryRed.withOpacity(0.5)),
                    ),
                    child: Text(
                      "${l10n.players}: ${substitutions.length}",
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: substitutions.length,
                itemBuilder: (context, index) {
                  final player = substitutions[index];
                  final playerId = player["id"].toString();
                  final isVoted = _isPlayerVoted(playerId);
                  final canVote = !hasVoteBeenSubmitted && votedPlayerId == null && widget.token != null && !isEventFinished;
                  final numberOfVotes = (player["number_of_votes"] as num?)?.toInt() ?? 0;
                  final userVote = player["user_vote"];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isVoted ? goldColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryRed, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: player['image'] != null
                                  ? Image.network(
                                player['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: primaryRed,
                                    child: Center(
                                      child: Text(
                                        player['number']?.toString() ?? '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                color: primaryRed,
                                child: Center(
                                  child: Text(
                                    player['number']?.toString() ?? '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${player['position']} • ${l10n.number}${player['number']}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: primaryRed,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${l10n.votes}: $numberOfVotes",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (userVote != null && userVote['rating'] != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.youVoted,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (!isEventFinished)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: canVote
                                      ? () => _voteForPlayer(playerId, player['name'])
                                      : (widget.token == null
                                      ? () => _showSnackBar(l10n.loginToVote, isError: true)
                                      : (hasVoteBeenSubmitted
                                      ? () => _showSnackBar(l10n.alreadyVotedForEvent, isError: true)
                                      : (votedPlayerId != null
                                      ? () => _showSnackBar(l10n.alreadySelectedPlayer, isError: true)
                                      : null))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isVoted
                                        ? Colors.green.shade700
                                        : (canVote ? primaryRed : Colors.grey.shade500),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(80, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(isVoted ? l10n.voted : l10n.vote),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryRed,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManOfTheMatchCard() {
    final l10n = AppLocalizations.of(context)!;

    if (manOfTheMatch == null || (manOfTheMatch!["number_of_votes"] as num?)?.toInt() == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryRed.withOpacity(0.2),
              goldColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: goldColor, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: goldColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.manOfTheMatchUnavailable,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.manOfTheMatchUnavailableMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final player = manOfTheMatch!;
    final numberOfVotes = (player["number_of_votes"] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryRed.withOpacity(0.9),
                  primaryRed.withOpacity(0.7),
                  goldColor.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: goldColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: StadiumPatternPainter(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: goldColor,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withOpacity(0.6),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: player['image'] != null
                                  ? Image.network(
                                player['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: primaryRed,
                                    child: Center(
                                      child: Text(
                                        player['number']?.toString() ?? '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                color: primaryRed,
                                child: Center(
                                  child: Text(
                                    player['number']?.toString() ?? '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -20,
                            right: -10,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: goldColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withOpacity(0.5),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        player['name']?.toString().toUpperCase() ?? l10n.unknown,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: goldColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sports_soccer, color: goldColor, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  player['position'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: goldColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.numbers, color: goldColor, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "${l10n.number}${player['number'] ?? '?'}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              goldColor.withOpacity(0.3),
                              goldColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: goldColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: goldColor,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${l10n.votes}: $numberOfVotes",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: goldColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildModernDetailItem(
                              icon: Icons.flag_rounded,
                              value: player['nationality'] ?? l10n.notAvailable,
                              label: l10n.nationality,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: goldColor.withOpacity(0.3),
                            ),
                            _buildModernDetailItem(
                              icon: Icons.cake_rounded,
                              value: '${player['age'] ?? l10n.notAvailable}',
                              label: l10n.age,
                            ),
                          ],
                        ),
                      ),
                      if (player['user_vote'] != null && player['user_vote']['comment'] != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: goldColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: goldColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment,
                                color: goldColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.yourComment,
                                      style: TextStyle(
                                        color: goldColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      player['user_vote']['comment'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTag({required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: goldColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topThree = topVotedPlayers;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isEventFinished ? Colors.black : const Color(0xFF0A1F1A),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEventFinished) ...[
              Icon(
                Icons.emoji_events,
                color: goldColor,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              isEventFinished ? l10n.manOfTheMatch : l10n.voteManOfTheMatch,
              style: const TextStyle(
                fontFamily: "Urbanist",
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
            if (isEventFinished) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.emoji_events,
                color: goldColor,
                size: 20,
              ),
            ],
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_rounded, size: 18, color: primaryRed),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, size: 18, color: primaryRed),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildInfoDialog(),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE41E26),
        ),
      )
          : Container(
        height: screenHeight - appBarHeight,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - appBarHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  if (isEventFinished)
                    _buildManOfTheMatchCard()
                  else ...[
                    if (topThree.isNotEmpty)
                      Container(
                        height: 95,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            if (topThree.length > 1)
                              Expanded(
                                child: _buildPodiumPlayer(
                                  player: topThree[1],
                                  place: 2,
                                  color: silverColor,
                                ),
                              ),
                            if (topThree.isNotEmpty)
                              Expanded(
                                child: _buildPodiumPlayer(
                                  player: topThree[0],
                                  place: 1,
                                  color: goldColor,
                                ),
                              ),
                            if (topThree.length > 2)
                              Expanded(
                                child: _buildPodiumPlayer(
                                  player: topThree[2],
                                  place: 3,
                                  color: bronzeColor,
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    Container(
                      height: 530,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: FadeTransition(
                          opacity: _fabAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  pitchLightGreen,
                                  pitchGreen,
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: FootballPitchPainter(),
                                  size: Size.infinite,
                                ),

                                ...playerPositions.entries.map((entry) {
                                  final playerData = entry.value;
                                  final player = playerData['player'];
                                  final position = playerData['position'] as Offset;
                                  final playerId = player["id"].toString();
                                  final numberOfVotes = (player["number_of_votes"] as num?)?.toInt() ?? 0;
                                  final hasVoted = _isPlayerVoted(playerId);

                                  return Positioned(
                                    left: position.dx * (MediaQuery.of(context).size.width - 48) - 30,
                                    top: position.dy * 450 - 40,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showPlayerDetailsModal(player);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.elasticOut,
                                        width: 70,
                                        height: 100,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: hasVoted
                                                      ? goldColor
                                                      : Colors.white,
                                                  width: hasVoted ? 3 : 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: hasVoted
                                                        ? goldColor.withOpacity(0.6)
                                                        : Colors.black.withOpacity(0.3),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: player['image'] != null
                                                    ? Image.network(
                                                  player['image'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: primaryRed,
                                                      child: Center(
                                                        child: Text(
                                                          player['number']?.toString() ?? '?',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                                    : Container(
                                                  color: primaryRed,
                                                  child: Center(
                                                    child: Text(
                                                      player['number']?.toString() ?? '?',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            if (hasVoted)
                                              Positioned(
                                                top: -5,
                                                right: -5,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: goldColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white, width: 2),
                                                  ),
                                                  child: const Icon(
                                                    Icons.thumb_up,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),

                                            Positioned(
                                              bottom: 20,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: hasVoted
                                                      ? goldColor
                                                      : Colors.black.withOpacity(0.8),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    player['number']?.toString() ?? '?',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              top: 72,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _getShortName(player['name']),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: primaryRed,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "$numberOfVotes",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    if (hasVoteBeenSubmitted) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryRed.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.alreadyVotedMessage,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (widget.token == null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.orange, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.loginToVoteMessage,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Center(
                      child: ScaleTransition(
                        scale: _fabAnimation,
                        child: ElevatedButton.icon(
                          onPressed: substitutions.isNotEmpty ? _showSubstitutionsList : null,
                          icon: const Icon(Icons.people_outline, color: Colors.white),
                          label: Text(
                            "${l10n.seeSubstitutes} (${substitutions.length})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: substitutions.isNotEmpty ? primaryRed : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPlayer({
    required Map<String, dynamic> player,
    required int place,
    required Color color,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final playerId = player["id"].toString();
    final numberOfVotes = (player["number_of_votes"] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _showPlayerDetailsModal(player),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: player['image'] != null
                    ? Image.network(
                  player['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryRed,
                      child: Center(
                        child: Text(
                          place.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: primaryRed,
                  child: Center(
                    child: Text(
                      place.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getShortName(player['name']),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$numberOfVotes",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDialog() {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: const Color(0xFF1A2E24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 30,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.voteManOfTheMatch,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("👆", l10n.infoTapPlayer),
            const SizedBox(height: 12),
            _buildInfoRow("👍", l10n.infoVoteFavorite),
            const SizedBox(height: 12),
            _buildInfoRow("💬", l10n.infoAddComment),
            const SizedBox(height: 12),
            _buildInfoRow("🏆", l10n.infoTopThree),
            const SizedBox(height: 12),
            _buildInfoRow("✅", l10n.infoSingleVote),
            const SizedBox(height: 12),
            _buildInfoRow("⏰", l10n.infoVotingOpen),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: primaryRed,
              ),
              child: Text(
                l10n.gotIt,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class FootballPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      paint,
    );

    canvas.drawLine(
      Offset(10, size.height / 2),
      Offset(size.width - 10, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.1,
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height - 30, size.width * 0.6, 20),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height - 40),
      2,
      paint..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, 10, size.width * 0.6, 20),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, 30),
      2,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StadiumPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = (i * size.height / 4) + size.height / 8;

      path.moveTo(0, yOffset);
      path.quadraticBezierTo(
        size.width / 2,
        yOffset + 30,
        size.width,
        yOffset,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}