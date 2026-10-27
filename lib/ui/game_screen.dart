import 'package:flutter/material.dart';

import '../model/game.dart';
import 'board_view.dart';
import 'control_panel.dart';
import 'players_panel.dart';
import 'setup_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.names});

  final List<String> names;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Game _game = Game(names: widget.names);

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _newGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5C5C),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _game,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              final controls = ControlPanel(game: _game, onNewGame: _newGame);
              final players = PlayersPanel(game: _game);
              final landscape = constraints.maxWidth / constraints.maxHeight >= 1.3;
              if (landscape) {
                return Center(
                  child: FittedBox(
                    child: BoardView(
                      game: _game,
                      left: SingleChildScrollView(child: players),
                      right: SingleChildScrollView(child: controls),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  FittedBox(child: BoardView(game: _game)),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [controls, const SizedBox(height: 12), players],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
