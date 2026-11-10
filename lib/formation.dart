import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FootballFormationPage extends StatefulWidget {
  final String? token;
  final String? eventId;
  final String? organizationId;
  final Map<String, dynamic>? eventData;
  final List<dynamic>? players;

  const FootballFormationPage({
    Key? key,
    this.token,
    this.eventId,
    this.organizationId,
    this.eventData,
    this.players,
  }) : super(key: key);

  @override
  _FootballFormationPageState createState() => _FootballFormationPageState();
}

class _FootballFormationPageState extends State<FootballFormationPage> with TickerProviderStateMixin {
  String selectedFormation = '4-3-3';
  Map<String, dynamic>? selectedPlayer;
  Map<String, dynamic> playerPositions = {};
  List<dynamic> wydadPlayers = [];

  late AnimationController _formationAnimationController;
  late Animation<double> _formationAnimation;

  final Color primaryRed = const Color(0xFFE41E26);
  final Color pitchGreen = const Color(0xFF1B4D3E);
  final Color pitchLightGreen = const Color(0xFF2E7D5E);

  final List<String> formations = [
    '4-3-3', '4-4-2', '3-5-2', '3-4-3',
    '4-2-3-1', '5-3-2', '4-1-4-1', '3-6-1',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormationAnimation();
    _initializeMockData();
  }

  void _initializeMockData() {
    wydadPlayers = [
      // Gardiens
      {
        "id": 1,
        "name": "El Mehdi Benabid",
        "number": "16",
        "position": "Gardien de but",
        "position_type": "gardien",
        "nationality": "Maroc",
        "age": 28,
        "image": "assets/benabid.png",
      },
      {
        "id": 2,
        "name": "Youssef El Motie",
        "number": "32",
        "position": "Gardien de but",
        "position_type": "gardien",
        "nationality": "Maroc",
        "age": 31,
        "image": "assets/elmotie.png",
      },

      // Défenseurs
      {
        "id": 5,
        "name": "Ayman El Wafi",
        "number": "3",
        "position": "Défenseur central",
        "position_type": "defenseur",
        "nationality": "Maroc",
        "age": 21,
        "image": "assets/wafi.png",
      },
      {
        "id": 6,
        "name": "Bart Meijers",
        "number": "22",
        "position": "Défenseur central",
        "position_type": "defenseur",
        "nationality": "Pays-Bas",
        "age": 29,
        "image": "assets/meijers.png",
      },
      {
        "id": 7,
        "name": "Amine Aboulfath",
        "number": "4",
        "position": "Défenseur central",
        "position_type": "defenseur",
        "nationality": "Maroc",
        "age": 28,
        "image": "assets/amine.png",
      },
      {
        "id": 8,
        "name": "Guilherme Ferreira",
        "number": "14",
        "position": "Défenseur central",
        "position_type": "defenseur",
        "nationality": "Brésil",
        "age": 26,
        "image": "assets/ferreira.png",
      },
      {
        "id": 10,
        "name": "Ayoub Boucheta",
        "number": "24",
        "position": "Arrière gauche",
        "position_type": "defenseur",
        "nationality": "Maroc",
        "age": 32,
        "image": "assets/boucheta.png",
      },
      {
        "id": 12,
        "name": "Mohamed Moufid",
        "number": "2",
        "position": "Arrière droit",
        "position_type": "defenseur",
        "nationality": "Maroc",
        "age": 25,
        "image": "assets/moufid.png",
      },

      // Milieux
      {
        "id": 15,
        "name": "Abdelghafour Lamirat",
        "number": "15",
        "position": "Milieu défensif",
        "position_type": "milieu",
        "nationality": "Maroc",
        "age": 28,
        "image": "assets/lamirat.png",
      },
      {
        "id": 18,
        "name": "Walid Sabbar",
        "number": "6",
        "position": "Milieu central",
        "position_type": "milieu",
        "nationality": "Maroc",
        "age": 29,
        "image": "assets/walid.png",
      },

      // Attaquants
      {
        "id": 25,
        "name": "Mohamed Rayhi",
        "number": "8",
        "position": "Ailier gauche",
        "position_type": "attaquant",
        "nationality": "Pays-Bas",
        "age": 31,
        "image": "assets/rayhi.png",
      },
      {
        "id": 28,
        "name": "Zouhair El Moutaraji",
        "number": "7",
        "position": "Ailier gauche",
        "position_type": "attaquant",
        "nationality": "Maroc",
        "age": 29,
        "image": "assets/motaraji.png",
      },
      {
        "id": 30,
        "name": "Hakim Ziyech",
        "number": "10",
        "position": "Ailier droit",
        "position_type": "milieu",
        "nationality": "Maroc",
        "age": 32,
        "image": "assets/ziyach.png",
      },
      {
        "id": 32,
        "name": "Nordin Amrabat",
        "number": "10",
        "position": "Ailier droit",
        "position_type": "attaquant",
        "nationality": "Maroc",
        "age": 38,
        "image": "assets/amrabat.png",
      },
      {
        "id": 33,
        "name": "Hamza Hannouri",
        "number": "19",
        "position": "Avant-centre",
        "position_type": "attaquant",
        "nationality": "Maroc",
        "age": 27,
        "image": "assets/hannouri.png",
      },
    ];

    _initializePositions();
  }

  void _initializeFormationAnimation() {
    _formationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _formationAnimation = CurvedAnimation(
      parent: _formationAnimationController,
      curve: Curves.easeInOutCubic,
    );
  }

  void _initializePositions() {
    _assignPlayersToFormation(selectedFormation);
  }

  void _assignPlayersToFormation(String formation) {
    setState(() {
      playerPositions.clear();

      final players = wydadPlayers;

      final goalkeepers = players.where((p) => p["position_type"] == "gardien").toList();
      final defenders = players.where((p) => p["position_type"] == "defenseur").toList();
      final midfielders = players.where((p) => p["position_type"] == "milieu").toList();
      final forwards = players.where((p) => p["position_type"] == "attaquant").toList();

      if (formation == '4-3-3') {
        _assign433(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '4-4-2') {
        _assign442(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '3-5-2') {
        _assign352(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '3-4-3') {
        _assign343(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '4-2-3-1') {
        _assign4231(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '5-3-2') {
        _assign532(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '4-1-4-1') {
        _assign4141(goalkeepers, defenders, midfielders, forwards);
      } else if (formation == '3-6-1') {
        _assign361(goalkeepers, defenders, midfielders, forwards);
      }
    });

    _formationAnimationController.reset();
    _formationAnimationController.forward();
  }

  void _assign433(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'LB', const Offset(0.2, 0.75));
    _assignPosition(defenders, 'CB1', const Offset(0.4, 0.75));
    _assignPosition(defenders, 'CB2', const Offset(0.6, 0.75));
    _assignPosition(defenders, 'RB', const Offset(0.8, 0.75));
    _assignPosition(midfielders, 'CDM', const Offset(0.5, 0.55));
    _assignPosition(midfielders, 'CM1', const Offset(0.3, 0.45));
    _assignPosition(midfielders, 'CM2', const Offset(0.7, 0.45));
    _assignPosition(forwards, 'LW', const Offset(0.2, 0.25));
    _assignPosition(forwards, 'ST', const Offset(0.5, 0.15));
    _assignPosition(forwards, 'RW', const Offset(0.8, 0.25));
  }

  void _assign442(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'LB', const Offset(0.2, 0.75));
    _assignPosition(defenders, 'CB1', const Offset(0.4, 0.75));
    _assignPosition(defenders, 'CB2', const Offset(0.6, 0.75));
    _assignPosition(defenders, 'RB', const Offset(0.8, 0.75));
    _assignPosition(midfielders, 'LM', const Offset(0.2, 0.5));
    _assignPosition(midfielders, 'CM1', const Offset(0.4, 0.45));
    _assignPosition(midfielders, 'CM2', const Offset(0.6, 0.45));
    _assignPosition(midfielders, 'RM', const Offset(0.8, 0.5));
    _assignPosition(forwards, 'ST1', const Offset(0.35, 0.2));
    _assignPosition(forwards, 'ST2', const Offset(0.65, 0.2));
  }

  void _assign352(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'CB1', const Offset(0.25, 0.75));
    _assignPosition(defenders, 'CB2', const Offset(0.5, 0.8));
    _assignPosition(defenders, 'CB3', const Offset(0.75, 0.75));
    _assignPosition(midfielders, 'LWB', const Offset(0.1, 0.6));
    _assignPosition(midfielders, 'CDM1', const Offset(0.35, 0.55));
    _assignPosition(midfielders, 'CDM2', const Offset(0.65, 0.55));
    _assignPosition(midfielders, 'RWB', const Offset(0.9, 0.6));
    _assignPosition(midfielders, 'CAM', const Offset(0.5, 0.4));
    _assignPosition(forwards, 'ST1', const Offset(0.35, 0.15));
    _assignPosition(forwards, 'ST2', const Offset(0.65, 0.15));
  }

  void _assign343(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'CB1', const Offset(0.25, 0.8));
    _assignPosition(defenders, 'CB2', const Offset(0.5, 0.85));
    _assignPosition(defenders, 'CB3', const Offset(0.75, 0.8));
    _assignPosition(midfielders, 'LM', const Offset(0.15, 0.55));
    _assignPosition(midfielders, 'CM1', const Offset(0.4, 0.5));
    _assignPosition(midfielders, 'CM2', const Offset(0.6, 0.5));
    _assignPosition(midfielders, 'RM', const Offset(0.85, 0.55));
    _assignPosition(forwards, 'LW', const Offset(0.2, 0.2));
    _assignPosition(forwards, 'ST', const Offset(0.5, 0.15));
    _assignPosition(forwards, 'RW', const Offset(0.8, 0.2));
  }

  void _assign4231(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'LB', const Offset(0.2, 0.75));
    _assignPosition(defenders, 'CB1', const Offset(0.4, 0.8));
    _assignPosition(defenders, 'CB2', const Offset(0.6, 0.8));
    _assignPosition(defenders, 'RB', const Offset(0.8, 0.75));
    _assignPosition(midfielders, 'CDM1', const Offset(0.35, 0.6));
    _assignPosition(midfielders, 'CDM2', const Offset(0.65, 0.6));
    _assignPosition(midfielders, 'LAM', const Offset(0.25, 0.4));
    _assignPosition(midfielders, 'CAM', const Offset(0.5, 0.35));
    _assignPosition(midfielders, 'RAM', const Offset(0.75, 0.4));
    _assignPosition(forwards, 'ST', const Offset(0.5, 0.15));
  }

  void _assign532(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'LWB', const Offset(0.1, 0.7));
    _assignPosition(defenders, 'CB1', const Offset(0.3, 0.8));
    _assignPosition(defenders, 'CB2', const Offset(0.5, 0.85));
    _assignPosition(defenders, 'CB3', const Offset(0.7, 0.8));
    _assignPosition(defenders, 'RWB', const Offset(0.9, 0.7));
    _assignPosition(midfielders, 'CM1', const Offset(0.3, 0.5));
    _assignPosition(midfielders, 'CM2', const Offset(0.5, 0.45));
    _assignPosition(midfielders, 'CM3', const Offset(0.7, 0.5));
    _assignPosition(forwards, 'ST1', const Offset(0.35, 0.15));
    _assignPosition(forwards, 'ST2', const Offset(0.65, 0.15));
  }

  void _assign4141(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'LB', const Offset(0.2, 0.75));
    _assignPosition(defenders, 'CB1', const Offset(0.4, 0.8));
    _assignPosition(defenders, 'CB2', const Offset(0.6, 0.8));
    _assignPosition(defenders, 'RB', const Offset(0.8, 0.75));
    _assignPosition(midfielders, 'CDM', const Offset(0.5, 0.6));
    _assignPosition(midfielders, 'LM', const Offset(0.2, 0.4));
    _assignPosition(midfielders, 'CM1', const Offset(0.4, 0.45));
    _assignPosition(midfielders, 'CM2', const Offset(0.6, 0.45));
    _assignPosition(midfielders, 'RM', const Offset(0.8, 0.4));
    _assignPosition(forwards, 'ST', const Offset(0.5, 0.15));
  }

  void _assign361(List goalkeepers, List defenders, List midfielders, List forwards) {
    _assignPosition(goalkeepers, 'GK', const Offset(0.5, 0.9));
    _assignPosition(defenders, 'CB1', const Offset(0.25, 0.8));
    _assignPosition(defenders, 'CB2', const Offset(0.5, 0.85));
    _assignPosition(defenders, 'CB3', const Offset(0.75, 0.8));
    _assignPosition(midfielders, 'LWB', const Offset(0.1, 0.6));
    _assignPosition(midfielders, 'CM1', const Offset(0.3, 0.5));
    _assignPosition(midfielders, 'CM2', const Offset(0.5, 0.45));
    _assignPosition(midfielders, 'CM3', const Offset(0.7, 0.5));
    _assignPosition(midfielders, 'RWB', const Offset(0.9, 0.6));
    _assignPosition(midfielders, 'CAM', const Offset(0.5, 0.3));
    _assignPosition(forwards, 'ST', const Offset(0.5, 0.1));
  }

  void _assignPosition(List players, String positionKey, Offset position) {
    if (players.isNotEmpty) {
      final player = players.removeAt(0);
      playerPositions[positionKey] = {
        'player': player,
        'position': position,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F1A),
      appBar: AppBar(
        title: const Text(
          "COMPOSITION D'ÉQUIPE",
          style: TextStyle(
            fontFamily: "Urbanist",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A1F1A),
                const Color(0xFF1B4D3E).withOpacity(0.9),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Formation selector - Grille 4x2
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 8.0;
                final totalSpacing = spacing * 3;
                final availableWidth = constraints.maxWidth - totalSpacing;
                final buttonWidth = availableWidth * 0.23;
                final buttonHeight = buttonWidth / 1.2;

                return GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: buttonWidth / buttonHeight,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: formations.map((formation) {
                    final isSelected = selectedFormation == formation;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFormation = formation;
                          _assignPlayersToFormation(formation);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryRed,
                              const Color(0xFFB71C1C),
                            ],
                          )
                              : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 0,
                            )
                          ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formation,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 2,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Football pitch with player portraits
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _formationAnimation,
                child: Container(
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
                    child: Stack(
                      children: [
                        // Pitch background
                        Container(
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
                          child: CustomPaint(
                            painter: FootballPitchPainter(),
                            size: Size.infinite,
                          ),
                        ),

                        // Player portraits - NO CIRCLES, just images
                        ...playerPositions.entries.map((entry) {
                          final playerData = entry.value;
                          final player = playerData['player'];
                          final position = playerData['position'] as Offset;
                          final isSelected = selectedPlayer == player;

                          return Positioned(
                            left: position.dx * (MediaQuery.of(context).size.width - 48) - 30,
                            top: position.dy * (MediaQuery.of(context).size.height * 0.6) - 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPlayer = player;
                                });
                                _showPlayerDetailsModal(player);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.elasticOut,
                                width: 70,
                                height: 90,
                                child: Stack(
                                  children: [
                                    // Player portrait (rectangle style FIFA)
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? primaryRed : Colors.white,
                                          width: isSelected ? 3 : 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? primaryRed.withOpacity(0.6)
                                                : Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          player['image'] ?? 'assets/ziyach.png',
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
                                        ),
                                      ),
                                    ),

                                    // Number plate below portrait (like FIFA cards)
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryRed : Colors.black.withOpacity(0.8),
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

                                    // Player name
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
          ),
        ],
      ),
    );
  }

  String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}. ${parts.last}";
    }
    return fullName;
  }

  void _substitutePlayer(Map<String, dynamic> currentPlayer, Map<String, dynamic> newPlayer) {
    String? positionKey;
    Offset? position;

    for (var entry in playerPositions.entries) {
      if (entry.value['player'] == currentPlayer) {
        positionKey = entry.key;
        position = entry.value['position'] as Offset;
        break;
      }
    }

    if (positionKey != null && position != null) {
      setState(() {
        playerPositions[positionKey!] = {
          'player': newPlayer,
          'position': position,
        };
        selectedPlayer = newPlayer;
      });

      _formationAnimationController.reset();
      _formationAnimationController.forward();
    }
  }

  void _showSubstitutionDialog(Map<String, dynamic> currentPlayer) {
    final availablePlayers = wydadPlayers.where((p) =>
    p != currentPlayer &&
        !playerPositions.values.any((pos) => pos['player'] == p)
    ).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        title: const Text(
          "Remplaçant",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              final player = availablePlayers[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryRed, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(
                      player['image'] ?? 'assets/default_player.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: primaryRed,
                          child: Center(
                            child: Text(
                              player['number']?.toString() ?? '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                title: Text(
                  player['name'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  player['position'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                onTap: () {
                  _substitutePlayer(currentPlayer, player);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPlayerDetailsModal(Map<String, dynamic> player) {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Player portrait in rectangle (FIFA style)
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
                child: Image.asset(
                  player['image'] ?? 'assets/default_player.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryRed,
                      child: Center(
                        child: Text(
                          player['number']?.toString() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Player name
            Text(
              player['name'] ?? 'Joueur inconnu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Position and number
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
                    "N°${player['number'] ?? '?'}",
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

            // Player details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailItem(
                  icon: Icons.flag_outlined,
                  label: 'Nationalité',
                  value: player['nationality'] ?? 'N/A',
                ),
                _buildDetailItem(
                  icon: Icons.cake_outlined,
                  label: 'Âge',
                  value: '${player['age'] ?? 'N/A'} ans',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to rating page
                    },
                    icon: const Icon(Icons.star_border),
                    label: const Text('Noter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubstitutionDialog(player);
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Remplacer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fermer',
                  style: TextStyle(
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