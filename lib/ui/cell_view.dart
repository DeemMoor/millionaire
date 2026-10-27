import 'package:flutter/material.dart';

import '../model/board.dart';
import '../model/game.dart';
import '../model/money.dart';

class CellView extends StatelessWidget {
  const CellView({super.key, required this.cell, this.owner});

  final BoardCell cell;
  final Player? owner;

  @override
  Widget build(BuildContext context) {
    final fg = cell.color.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
    final borderColor = owner?.color ??
        (cell.kind == CellKind.pot ? Colors.red.shade700 : Colors.black26);
    final borderWidth = owner != null || cell.kind == CellKind.pot ? 4.0 : 1.0;
    return Container(
      margin: const EdgeInsets.all(1.5),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cell.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14),
        child: _content(fg),
      ),
    );
  }

  Widget _content(Color fg) => switch (cell.kind) {
        CellKind.firm => Column(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(cell.name, textAlign: TextAlign.center),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    color: Colors.white,
                    child: Text(
                      '${cell.number}',
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(formatMoney(cell.amount),
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        CellKind.bank => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('BANK', style: TextStyle(fontSize: 16)),
              Icon(Icons.account_balance, color: Colors.blue.shade800, size: 22),
              FittedBox(child: Text(formatMoney(cell.amount))),
            ],
          ),
        CellKind.start => Center(
            child: Transform.rotate(
              angle: -0.5,
              child: Text('Start',
                  style: TextStyle(fontSize: 22, color: Colors.blue.shade800)),
            ),
          ),
        CellKind.elevator => CustomPaint(
            painter: _DiagonalPainter(Colors.blue.shade900),
            child: const Stack(
              children: [
                Align(alignment: Alignment.topLeft, child: Text('1,2,3 →')),
                Align(alignment: Alignment.bottomRight, child: Text('4,5,6 ↓')),
              ],
            ),
          ),
        CellKind.crisis => ClipRect(
            child: Center(
              child: Transform.rotate(
                angle: -0.6,
                child: Text(
                  'CRISIS\nCRISIS\nCRISIS',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700, height: 1.1),
                ),
              ),
            ),
          ),
        CellKind.treasure => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const FittedBox(child: Text('Treasure')),
              Text('\$', style: TextStyle(fontSize: 26, color: Colors.blue.shade800)),
              FittedBox(
                child: Text(formatMoney(cell.amount),
                    style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
          ),
        CellKind.pot => Center(
            child: FittedBox(
              child: Text(
                '\$  ${formatMoney(cell.amount)} \$  ',
                style: TextStyle(fontSize: 34, color: Colors.red.shade700),
              ),
            ),
          ),
      };
}

class _DiagonalPainter extends CustomPainter {
  _DiagonalPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.9),
      Offset(size.width * 0.85, size.height * 0.1),
      Paint()
        ..color = color
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_DiagonalPainter oldDelegate) => oldDelegate.color != color;
}

void showCellInfo(BuildContext context, Game game, BoardCell cell) {
  final owner = cell.isFirm ? game.ownerOf(cell) : null;
  final lines = switch (cell.kind) {
    CellKind.firm => [
        'Цена: ${formatMoney(cell.amount)}',
        'Рента: ${formatMoney(game.rentFor(cell))}',
        'Владелец: ${owner?.name ?? 'свободна'}',
      ],
    CellKind.bank => ['Выдаёт ${formatMoney(cell.amount)}'],
    CellKind.elevator => [
        'Выпало 1–3: едешь дальше по кругу.',
        'Выпало 4–6: падаешь в шахту.',
        'Из шахты выход только точным попаданием на элеватор.',
      ],
    CellKind.pot => ['Приз ${formatMoney(cell.amount)} за попадание из шахты'],
    _ => ['Правила этого поля ещё не придуманы'],
  };
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(cell.isFirm ? '${cell.number}. ${cell.name}' : cell.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line)],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    ),
  );
}
