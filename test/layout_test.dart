import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millionaire/model/board.dart';
import 'package:millionaire/ui/board_view.dart';
import 'package:millionaire/ui/game_screen.dart';
import 'package:millionaire/ui/players_panel.dart';

void main() {
  testWidgets('players panel fits the board with every firm owned', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(names: ['Вася', 'Клара', 'Тед'])),
    );
    final state = tester.state(find.byType(GameScreen)) as dynamic;
    final game = state.game;
    for (final n in firmsByNumber.keys) {
      game.owners[n] = n <= 30 ? 2 : n % 3; // one hoarder
    }
    game.notifyListeners();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final board = tester.getRect(find.byType(BoardView));
    final panel = tester.getRect(find.byType(PlayersPanel));
    final scale = board.height / boardSize.height;
    // The panel area ends where the bottom row of cells starts.
    expect(
      panel.bottom,
      lessThanOrEqualTo(board.top + (boardSize.height - edgeH) * scale),
    );
  });
}
