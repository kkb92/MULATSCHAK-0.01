import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Player {
  String name;
  int points;
  bool isSelectable;
  bool isVisible; // Neue Eigenschaft für den Sichtbarkeitsstatus

  Player(this.name, this.points, this.isSelectable, {this.isVisible = true});
}

class PointsOption {
  String label;
  int value;

  PointsOption(this.label, this.value);

  static PointsOption plusOne() {
    return PointsOption('+1', 1);
  }

  static PointsOption plusTwo() {
    return PointsOption('+2', 2);
  }

  static PointsOption plusThree() {
    return PointsOption('+3', 3);
  }

  static PointsOption plusFour() {
    return PointsOption('+4', 4);
  }
}

class PointsMultiplier {
  String label;
  int multiplier;

  PointsMultiplier(this.label, this.multiplier);
}

class RoundResult {
  int roundNumber;
  Map<String, int> playerPoints;

  RoundResult(this.roundNumber, this.playerPoints);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Player> players = [];
  int selectedPlayerCount = 3;
  bool pointsGiven = false; // Neue Variable für den Zustand der Punktevergabe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('MULATSCHAK / WELI'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SPIELERAUSWAHL',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 3; i <= 5; i++)
                  ElevatedButton(
                    onPressed: () async {
                      // Setze die ausgewählte Spieleranzahl
                      setState(() {
                        selectedPlayerCount = i;
                      });

                      // Lasse die Spieler benennen
                      await _getPlayersNames();

                      // Navigiere zur nächsten Seite
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayersTablePage(players),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPlayerCount == i ? Colors.blue[200] : Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      '$i Spieler',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPlayersNames() async {
    // Lasse den Benutzer die Spieler benennen
    List<Player> selectedPlayers = [];
    for (int i = 0; i < selectedPlayerCount; i++) {
      String? playerName = await _getPlayerName(context, i + 1);
      selectedPlayers.add(Player(playerName ?? 'Spieler ${i + 1}', 15, true));
    }

    // Setze die ausgewählten Spieler
    setState(() {
      players = selectedPlayers;
    });
  }

  Future<String?> _getPlayerName(BuildContext context, int playerNumber) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Spieler $playerNumber benennen'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class PlayersTablePage extends StatefulWidget {
  final List<Player> players;

  PlayersTablePage(this.players);

  @override
  _PlayersTablePageState createState() => _PlayersTablePageState();
}

class _PlayersTablePageState extends State<PlayersTablePage> {
  Player? selectedPlayer;
  PointsOption? selectedPointsOption;
  PointsMultiplier? selectedMultiplier;
  int calculatedPoints = 0;
  int roundNumber = 1;
  List<RoundResult> roundResults = [];

  List<PointsOption> pointsOptions = [
    PointsOption('-5', -5),
    PointsOption('-4', -4),
    PointsOption('-3', -3),
    PointsOption('-2', -2),
    PointsOption('-1', -1),
  ];

  List<PointsMultiplier> pointsMultipliers = [
    PointsMultiplier('x1', 1),
    PointsMultiplier('x2', 2),
    PointsMultiplier('x4', 4),
    PointsMultiplier('x8', 8),
    PointsMultiplier('x16', 16),
    PointsMultiplier('x32', 32),
    PointsMultiplier('x64', 64),
  ];

  @override
  void initState() {
    super.initState();
    // Set the default multiplier when the state is initialized
    selectedMultiplier = pointsMultipliers[0]; // Wähle den ersten Multiplikator aus
  }

  Map<String, int> calculateTotalPointsPerPlayer() {
    Map<String, int> totalPointsPerPlayer = {};

    for (var player in widget.players) {
      totalPointsPerPlayer[player.name] = 0;
    }

    for (var roundResult in roundResults) {
      for (var entry in roundResult.playerPoints.entries) {
        // Berücksichtige nur Punkte ab 0 (+-1)
        if (entry.value >= 0) {
          totalPointsPerPlayer[entry.key] = (totalPointsPerPlayer[entry.key] ?? 0) + entry.value;
        }
      }
    }

    // Sortiere die Spieler basierend auf ihren Gesamtpunkten in aufsteigender Reihenfolge
    var sortedPlayers = totalPointsPerPlayer.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Erstelle eine neue Map mit sortierten Einträgen
    Map<String, int> sortedTotalPointsPerPlayer = {};
    for (var entry in sortedPlayers) {
      sortedTotalPointsPerPlayer[entry.key] = entry.value;
    }

    return sortedTotalPointsPerPlayer;
  }

  void resetPoints() {
    setState(() {
      for (var player in widget.players) {
        player.points = 15;
      }
    });
  }

  void endRound() {
    Map<String, int> playerPoints = {};
    for (var player in widget.players) {
      playerPoints[player.name] = player.points;
    }

    RoundResult roundResult = RoundResult(roundNumber, playerPoints);
    roundResults.add(roundResult);
    roundNumber++;

    resetPoints();
  }

  void resetRound() {
    setState(() {
      roundNumber = 1;
      roundResults.clear();
      resetPoints();
    });
  }

  void showRoundResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, int> totalPointsPerPlayer = calculateTotalPointsPerPlayer();

        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PUNKTEÜBERSICHT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: roundResults.length,
                    itemBuilder: (context, index) {
                      RoundResult roundResult = roundResults[index];
                      return Card(
                        child: Column(
                          children: [
                            Text(
                              'Runde ${roundResult.roundNumber}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: roundResult.playerPoints.entries.map((entry) {
                                // Begrenze auf 0 Punkte
                                int displayedPoints = entry.value < 0 ? 0 : entry.value;

                                return Text(
                                  entry.key == 'Spieler 1' || entry.key == 'Spieler 2'
                                      ? '$displayedPoints'
                                      : '${entry.key}: $displayedPoints Punkte',
                                  style: TextStyle(
                                    fontWeight: entry.key == 'Spieler 1' || entry.key == 'Spieler 2'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'GESAMTPUNKTE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: totalPointsPerPlayer.entries.map((entry) {
                    // Begrenze auf 0 Punkte
                    int displayedPoints = entry.value < 0 ? 0 : entry.value;

                    return Text(
                      '${entry.key}: $displayedPoints Punkte',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyMPlus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      setState(() {
        selectedPlayer!.points += 20 * selectedMultiplier!.multiplier;

        // Den restlichen Spielern -20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points -= 20 * selectedMultiplier!.multiplier;
            if (player.points < 0) {
              player.points = 0;
            }
          }
        }
      });
    }
  }

  void _applyMMinus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      setState(() {
        selectedPlayer!.points -= 20 * selectedMultiplier!.multiplier;
        if (selectedPlayer!.points < 0) {
          selectedPlayer!.points = 0;
        }

        // Den restlichen Spielern +20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points += 20 * selectedMultiplier!.multiplier;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MULATSCHAK - WELI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                Player currentPlayer = widget.players[index];
                bool isSelected = selectedPlayer == currentPlayer;

                // Überprüfen Sie, ob der Spieler sichtbar ist, bevor Sie ihn im GridView erstellen
                if (currentPlayer.isVisible) {
                  return IgnorePointer(
                    ignoring: !currentPlayer.isVisible,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlayer = isSelected ? null : currentPlayer;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // Transparenter Rahmen
                            width: 1.0,
                          ),
                          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentPlayer.name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${currentPlayer.points}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: InkWell(
                                onTap: () {
                                  _handleLeftXButtonPress(currentPlayer);
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: InkWell(
                                onTap: () {
                                  _handleMinusButtonPress(currentPlayer);
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 24.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  _handleRightXButtonPress(currentPlayer);
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Rückgabewert für den Fall, dass der Spieler nicht sichtbar ist (ausgeblendet)
                  return Container();
                }
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showMultiplierMenu(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null ? Colors.blue[200] : Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedMultiplier != null
                          ? 'x${selectedMultiplier!.multiplier}'
                          : '*',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyMPlus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null ? Colors.redAccent : Colors.redAccent[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('M+'),
              ),

              ElevatedButton(
                onPressed: () {
                  _applyMMinus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null ? Colors.green : Colors.green[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('M-'),
              ),
            ],
          ),

          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-1', -1);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-1' ? Colors.blue[200] : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '-1',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-2', -2);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-2' ? Colors.blue[200] : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '-2',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-3', -3);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-3' ? Colors.blue[200] : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '-3',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-4', -4);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-4' ? Colors.blue[200] : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '-4',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-5', -5);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-5' ? Colors.blue[200] : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '-5',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (selectedPlayer != null &&
                      selectedPointsOption != null &&
                      selectedMultiplier != null) {
                    _applyPointsToPlayer(selectedPlayer!, selectedPointsOption!.value);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('ÜBERNEHMEN'),
              ),
              ElevatedButton(
                onPressed: () {
                  endRound();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('NEUE RUNDE'),
              ),
              ElevatedButton(
                onPressed: () {
                  resetRound();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('RESET'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              showRoundResults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text('ÜBERSICHT'),
          ),
        ],
      ),
    );
  }

  void _handleLeftXButtonPress(Player player) {
    // Behandele den Klick auf das linke X für den angegebenen Spieler
    // Füge +5 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 5 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
        });
      }
    }
  }

  void _handleRightXButtonPress(Player player) {
    // Behandle den Klick auf das rechte X für den angegebenen Spieler
    // Füge +10 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 10 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
        });
      }
    }
  }

  void _handleMinusButtonPress(Player player) {
    // Behandle den Klick auf den Minus-Button für den angegebenen Spieler
    // Füge +1 Punkt zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
        });
      }
    }
  }

  void _applyPlusOne(Player player) {
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
      });
    }
  }

  void _applyPointsToPlayer(Player player, int points) {
    // Füge Punkte zum Spieler hinzu unter Berücksichtigung des Multiplikators
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += points * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
        });
      }
    }
  }


  void _showMultiplierMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          child: Column(
            children: pointsMultipliers.map((multiplier) {
              return ListTile(
                title: Text('x${multiplier.multiplier}'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedMultiplier = multiplier;
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
