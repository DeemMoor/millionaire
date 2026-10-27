import 'package:flutter/material.dart';

import '../model/board.dart';
import '../model/game.dart';
import 'cell_view.dart';

const cellW = 84.0;

/// Height of the top and bottom rows.
const edgeH = 104.0;

/// Height of the side rows; taller to leave room for the panels inside.
const sideH = 112.0;
const boardSize = Size(cellW * 15, edgeH * 2 + sideH * 5);
const _tokenSize = 24.0;

double _rowTop(int row) => row == 0 ? 0 : edgeH + (row - 1) * sideH;
double _rowHeight(int row) => row == 0 || row == 6 ? edgeH : sideH;

Rect _grid(int col, int row, [int spanCols = 1, int spanRows = 1]) {
  final top = _rowTop(row);
  final bottom = _rowTop(row + spanRows - 1) + _rowHeight(row + spanRows - 1);
  return Rect.fromLTRB(col * cellW, top, (col + spanCols) * cellW, bottom);
}

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
      _ => _grid(6, i, 2),
    };

/// Where the side panels go: left and right of the shaft.
final leftPanelRect = _grid(1, 1, 5, 5).deflate(10);
final rightPanelRect = _grid(8, 1, 6, 5).deflate(10);

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
          Positioned.fromRect(
            rect: _grid(8, 3, 6, 3).deflate(10),
            child: const _Watermark(),
          ),
          for (var i = 0; i < ringCells.length; i++)
            _cell(context, ringRect(i), ringCells[i]),
          for (var i = 1; i < shaftCells.length; i++)
            _cell(context, shaftRect(i), shaftCells[i]),
          if (left != null) Positioned.fromRect(rect: leftPanelRect, child: left!),
          if (right != null) Positioned.fromRect(rect: rightPanelRect, child: right!),
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
      left: rect.left + 6 + index * (_tokenSize - 4),
      top: rect.top + 6,
      width: _tokenSize,
      height: _tokenSize,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              colors: [Color.lerp(player.color, Colors.white, 0.55)!, player.color],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black54)],
          ),
        ),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  const _Watermark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FittedBox(
        child: Text(
          'МИЛЛИОНЕР',
          style: TextStyle(
            fontFamily: 'RussoOne',
            fontSize: 64,
            color: Colors.white.withValues(alpha: 0.07),
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
