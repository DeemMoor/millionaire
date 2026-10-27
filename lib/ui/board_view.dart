import 'package:flutter/material.dart';

import '../model/board.dart';
import '../model/game.dart';
import 'cell_view.dart';

const cellW = 80.0;
const cellH = 90.0;
const boardSize = Size(cellW * 15, cellH * 7);
const _tokenSize = 22.0;

Rect _grid(int col, int row, [int spanCols = 1, int spanRows = 1]) =>
    Rect.fromLTWH(col * cellW, row * cellH, spanCols * cellW, spanRows * cellH);

/// Ring layout on a 15x7 grid, clockwise from the top-left corner.
Rect ringRect(int i) => switch (i) {
      < elevatorIndex => _grid(i, 0),
      elevatorIndex => _grid(6, 0, 2),
      <= 11 => _grid(i + 1, 0),
      12 => _grid(13, 0),
      13 => _grid(14, 0),
      <= 18 => _grid(14, i - 13),
      19 => _grid(14, 6),
      <= 33 => _grid(33 - i, 6),
      _ => _grid(0, 39 - i),
    };

/// The shaft hangs down from the elevator, the prize sits at its bottom.
Rect shaftRect(int i) => switch (i) {
      0 => ringRect(elevatorIndex),
      4 => _grid(5, 4, 4),
      _ => _grid(6, i, 2),
    };

Rect playerRect(Player p) =>
    p.inShaft ? shaftRect(p.shaftPos!) : ringRect(p.ringPos);

/// Fixed-size board in logical pixels; scale it with a FittedBox.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.game, this.left, this.right});

  final Game game;

  /// Optional widgets placed inside the board, left and right of the shaft.
  final Widget? left;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: boardSize,
      child: Stack(
        children: [
          for (var i = 0; i < ringCells.length; i++)
            _cell(context, ringRect(i), ringCells[i]),
          for (var i = 1; i < shaftCells.length; i++)
            _cell(context, shaftRect(i), shaftCells[i]),
          if (left != null)
            Positioned.fromRect(rect: _grid(1, 1, 4, 5).deflate(10), child: left!),
          if (right != null)
            Positioned.fromRect(rect: _grid(9, 1, 5, 5).deflate(10), child: right!),
          for (var i = 0; i < game.players.length; i++)
            if (!game.players[i].bankrupt) _token(i),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, Rect rect, BoardCell cell) => Positioned.fromRect(
        rect: rect,
        child: GestureDetector(
          onTap: () => showCellInfo(context, game, cell),
          child: CellView(cell: cell, owner: cell.isFirm ? game.ownerOf(cell) : null),
        ),
      );

  Widget _token(int index) {
    final player = game.players[index];
    final rect = playerRect(player);
    return AnimatedPositioned(
      key: ValueKey(index),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      left: rect.left + 8 + index * (_tokenSize + 2),
      top: rect.center.dy - _tokenSize / 2,
      width: _tokenSize,
      height: _tokenSize,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: player.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black54)],
          ),
        ),
      ),
    );
  }
}
