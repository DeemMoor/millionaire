import 'package:flutter/material.dart';

import '../model/board.dart';
import '../model/game.dart';
import '../model/money.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.game, required this.onNewGame});

  final Game game;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final player = game.currentPlayer;
    final status = switch (game.phase) {
      Phase.roll => 'Ходит ${player.name}${switch (player) {
          Player(inShaft: true) => ' (в шахте)',
          Player(ringPos: elevatorIndex) => ' (элеватор: 7–12 вниз)',
          _ => '',
        }}',
      Phase.buy => '${player.name}: купить ${player.cell.name}?',
      Phase.gameOver => 'Победитель: ${game.winner!.name}!',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final value in game.dice)
                Padding(padding: const EdgeInsets.all(6), child: DiceFace(value: value)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buttons(player),
          const SizedBox(height: 10),
          for (final line in game.log.reversed.take(4))
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buttons(Player player) => switch (game.phase) {
        Phase.roll => FilledButton(onPressed: game.roll, child: const Text('Бросать')),
        Phase.buy => Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: game.buy,
                  child: FittedBox(
                    child: Text('Купить за ${formatMoney(player.cell.amount)}'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: game.skip,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: const FittedBox(child: Text('Пропустить')),
                ),
              ),
            ],
          ),
        Phase.gameOver => FilledButton(onPressed: onNewGame, child: const Text('Новая игра')),
      };
}

class DiceFace extends StatelessWidget {
  const DiceFace({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5E43A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6D4C41), width: 2),
      ),
      child: CustomPaint(painter: _PipsPainter(value)),
    );
  }
}

class _PipsPainter extends CustomPainter {
  _PipsPainter(this.value);

  final int value;

  /// Pip slots on a 3x3 grid, row-major.
  static const _layouts = {
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF5D4037);
    final step = size.width / 4;
    for (final slot in _layouts[value]!) {
      final center = Offset(step * (slot % 3 + 1), step * (slot ~/ 3 + 1));
      canvas.drawCircle(center, size.width / 11, paint);
    }
  }

  @override
  bool shouldRepaint(_PipsPainter oldDelegate) => oldDelegate.value != value;
}
