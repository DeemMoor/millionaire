import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millionaire/ui/game_screen.dart';
import 'package:millionaire/ui/setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpGame(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(names: ['A', 'B', 'C'])),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('F1 opens help', (tester) async {
    await pumpGame(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.text('Понятно'), findsOneWidget);
  });

  testWidgets('F2 asks before dropping the game, then opens setup', (tester) async {
    await pumpGame(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.text('Текущая партия будет потеряна. Начать заново?'), findsOneWidget);
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(find.byType(SetupScreen), findsOneWidget);
  });

  testWidgets('menu shows the items with hotkeys', (tester) async {
    await pumpGame(tester);
    await tester.tap(find.text('Файл'));
    await tester.pumpAndSettle();
    expect(find.text('Новая игра'), findsOneWidget);
    expect(find.text('Выход'), findsOneWidget);
    expect(find.text('F2'), findsOneWidget);
  });
}
