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

  @visibleForTesting
  Game get game => _game;

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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [Color(0xFF13807A), Color(0xFF0B5C5C), Color(0xFF063A3A)],
            stops: [0, 0.6, 1],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _game,
            builder: (context, _) => LayoutBuilder(
              builder: (context, constraints) {
                final controls = ControlPanel(game: _game, onNewGame: _newGame);
                final players = PlayersPanel(game: _game);
                final landscape =
                    constraints.maxWidth / constraints.maxHeight >= 1.3;
                if (landscape) {
                  return Center(
                    child: FittedBox(
                      child: BoardView(
                        game: _game,
                        left: _ShrinkToFit(child: players),
                        right: _ShrinkToFit(child: controls),
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
                        children: [
                          controls,
                          const SizedBox(height: 12),
                          players,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Scales the child down when it is taller than the space given, instead of
/// letting it spill over the board.
class _ShrinkToFit extends StatelessWidget {
  const _ShrinkToFit({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: SizedBox(width: constraints.maxWidth, child: child),
      ),
    );
  }
}
