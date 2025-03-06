import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.deepPurple,
          backgroundColor: Colors.grey[50],
        ),
        useMaterial3: true,
      ),
      home: const TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late List<List<String>> board;
  String currentPlayer = 'X';
  String gameResult = '';
  int moveCount = 0;
  bool vsComputer = true;
  String difficulty = 'easy';
  int playerXScore = 0;
  int playerOScore = 0;
  bool isComputerThinking = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      currentPlayer = 'X';
      gameResult = '';
      moveCount = 0;
      isComputerThinking = false;
    });
    if (vsComputer && currentPlayer == 'O') _computerMove();
  }

  void _resetScores() {
    setState(() {
      playerXScore = 0;
      playerOScore = 0;
    });
    _initializeGame();
  }

  void _updateScore(String winner) {
    setState(() {
      if (winner == 'X') {
        playerXScore++;
      } else if (winner == 'O') {
        playerOScore++;
      }
    });
  }

  void _computerMove() {
    if (gameResult.isNotEmpty) return;

    setState(() => isComputerThinking = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      List<int> move;
      switch (difficulty) {
        case 'hard':
          move = _findBestMove();
          break;
        case 'medium':
          move = _findMediumMove();
          break;
        default:
          move = _findRandomMove();
      }

      setState(() {
        board[move[0]][move[1]] = 'O';
        moveCount++;
        isComputerThinking = false;

        if (_checkWin('O')) {
          gameResult = 'Computer Wins!';
          _updateScore('O');
        } else if (moveCount == 9) {
          gameResult = 'Draw!';
        } else {
          currentPlayer = 'X';
        }
      });
    });
  }

  List<int> _findRandomMove() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) emptyCells.add([i, j]);
      }
    }
    return emptyCells[_random.nextInt(emptyCells.length)];
  }

  List<int> _findMediumMove() {
    // Check for computer win
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          board[i][j] = 'O';
          if (_checkWin('O')) {
            board[i][j] = '';
            return [i, j];
          }
          board[i][j] = '';
        }
      }
    }

    // Block player win
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          board[i][j] = 'X';
          if (_checkWin('X')) {
            board[i][j] = '';
            return [i, j];
          }
          board[i][j] = '';
        }
      }
    }

    return _findRandomMove();
  }

  List<int> _findBestMove() {
    int bestScore = -1000;
    List<int> bestMove = [-1, -1];
    int originalMoveCount = moveCount;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          board[i][j] = 'O';
          moveCount++;
          int score = _minimax(false, -1000, 1000, 0);
          board[i][j] = '';
          moveCount = originalMoveCount;

          if (score > bestScore) {
            bestScore = score;
            bestMove = [i, j];
          }
        }
      }
    }
    return bestMove;
  }

  int _minimax(bool isMaximizing, int alpha, int beta, int depth) {
    if (_checkWin('O')) return 10 - depth;
    if (_checkWin('X')) return depth - 10;
    if (moveCount == 9) return 0;

    int bestScore = isMaximizing ? -1000 : 1000;
    String player = isMaximizing ? 'O' : 'X';

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          board[i][j] = player;
          moveCount++;
          int score = _minimax(!isMaximizing, alpha, beta, depth + 1);
          board[i][j] = '';
          moveCount--;

          if (isMaximizing) {
            bestScore = max(score, bestScore);
            alpha = max(alpha, bestScore);
          } else {
            bestScore = min(score, bestScore);
            beta = min(beta, bestScore);
          }

          if (beta <= alpha) break;
        }
      }
    }
    return bestScore;
  }

  bool _checkWin(String player) {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player && board[i][1] == player && board[i][2] == player) return true;
      if (board[0][i] == player && board[1][i] == player && board[2][i] == player) return true;
    }
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) return true;
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) return true;
    return false;
  }

  void _handleMove(int row, int col) {
    if (isComputerThinking || board[row][col].isNotEmpty || gameResult.isNotEmpty) return;

    setState(() {
      board[row][col] = currentPlayer;
      moveCount++;

      if (_checkWin(currentPlayer)) {
        gameResult = '${vsComputer && currentPlayer == 'O' ? 'Computer' : 'Player $currentPlayer'} Wins!';
        _updateScore(currentPlayer);
      } else if (moveCount == 9) {
        gameResult = 'Draw!';
      } else {
        currentPlayer = 'O';
        if (vsComputer) _computerMove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxGameSize = min(screenSize.width, screenSize.height * 0.6).clamp(200.0, 400.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width > 600 ? 50 : 16,
                      vertical: 20
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildScoreboard(),
                      const SizedBox(height: 20),
                      Container(
                        constraints: BoxConstraints(maxWidth: maxGameSize, maxHeight: maxGameSize),
                        child: _buildGameGrid(),
                      ),
                      SizedBox(height: screenSize.height > 800 ? 20 : 10),
                      _buildGameControls(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerScore('Player X', playerXScore, Colors.blue[800]!),
            _buildPlayerScore(
              vsComputer ? 'Computer' : 'Player O',
              playerOScore,
              Colors.red[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              int row = index ~/ 3;
              int col = index % 3;
              return _buildGridCell(row, col);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGridCell(int row, int col) {
    return GestureDetector(
      onTap: () => _handleMove(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blueGrey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              board[row][col],
              key: ValueKey(board[row][col]),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: board[row][col] == 'X'
                    ? Colors.blue[800]
                    : Colors.red[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              gameResult.isNotEmpty
                  ? gameResult
                  : isComputerThinking
                  ? 'Computer Thinking...'
                  : 'Current Player: $currentPlayer',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (gameResult.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.replay, size: 24),
              label: const Text('Play Again', style: TextStyle(fontSize: 18)),
              onPressed: _initializeGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Game Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text('Vs ${vsComputer ? 'Computer' : 'Player'}'),
                    value: vsComputer,
                    activeColor: Colors.blue[800],
                    inactiveTrackColor: Colors.grey[300],
                    onChanged: (value) {
                      setState(() => vsComputer = value!);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        this.setState(() {});
                      });
                    },
                  ),
                  if (vsComputer)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: DropdownButtonFormField<String>(
                        value: difficulty,
                        decoration: InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                        items: ['easy', 'medium', 'hard']
                            .map((mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(
                            mode.toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) => setState(() => difficulty = value!),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.restart_alt, size: 20),
                      label: const Text('Reset All Scores'),
                      onPressed: () {
                        _resetScores();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
