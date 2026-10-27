import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:millionaire/model/board.dart';
import 'package:millionaire/model/game.dart';

/// Returns the given die values in order.
class _FixedDice implements Random {
  _FixedDice(this.values);

  final List<int> values;

  @override
  int nextInt(int max) => values.removeAt(0) - 1;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('buying a free firm', () {
    final game = Game(random: _FixedDice([1, 2]));
    game.roll();
    expect(game.phase, Phase.buy);
    expect(game.currentPlayer.cell.name, 'Adidas');
    game.buy();
    expect(game.players[0].balance, 40000);
    expect(game.ownerOf(firmsByNumber[3]!), game.players[0]);
    expect(game.current, 1);
  });

  test('rent is 10% and doubles for a whole group', () {
    final game = Game(random: _FixedDice([1, 2, 1, 2]));
    game.roll();
    game.buy();
    game.roll();
    expect(game.players[1].balance, 49000);
    expect(game.players[0].balance, 41000);

    for (var n = 1; n <= 5; n++) {
      game.owners[n] = 0;
    }
    expect(game.rentFor(firmsByNumber[3]!), 2000);
    // A single-firm group gets no bonus.
    game.owners[27] = 0;
    expect(game.rentFor(firmsByNumber[27]!), 8500);
  });

  test('bank pays its amount', () {
    final game = Game(random: _FixedDice([3, 4]));
    game.roll();
    expect(game.players[0].balance, 60000);
    expect(game.phase, Phase.roll);
    expect(game.current, 1);
  });

  test('landing on the elevator just ends the turn', () {
    final game = Game(random: _FixedDice([2, 4]));
    game.roll();
    expect(game.players[0].ringPos, elevatorIndex);
    expect(game.players[0].inShaft, isFalse);
    expect(game.current, 1);
  });

  test('from the elevator 2-6 goes along the ring', () {
    final game = Game(random: _FixedDice([2, 3]));
    game.players[0].ringPos = elevatorIndex;
    game.roll();
    expect(game.players[0].inShaft, isFalse);
    expect(game.players[0].cell.name, 'Kawasaki');
  });

  test('from the elevator 7-12 goes down the shaft', () {
    final game = Game(random: _FixedDice([3, 4]));
    game.players[0].ringPos = elevatorIndex;
    game.roll();
    expect(game.players[0].inShaft, isTrue);
    expect(game.players[0].cell.name, 'Donald');
  });

  test('shaft loops until landing exactly on the elevator', () {
    final game = Game(
      random: _FixedDice([
        3, 5, // p0: elevator + 8 -> TipTop
        1, 2, 1, 2, // p1, p2: Adidas
        2, 4, // p0: TipTop + 6 -> prize
        2, 3, 2, 3, // p1, p2: Suzuki
        5, 6, // p0: prize + 11 -> elevator
      ]),
    );
    void skipOthers() {
      for (var i = 0; i < 2; i++) {
        game.roll();
        game.skip();
      }
    }

    game.players[0].ringPos = elevatorIndex;
    game.roll();
    expect(game.players[0].cell.name, 'TipTop');
    game.skip();
    skipOthers();
    game.roll();
    expect(game.players[0].cell.kind, CellKind.pot);
    expect(game.players[0].balance, 65000);
    skipOthers();
    game.roll();
    expect(game.players[0].inShaft, isFalse);
    expect(game.players[0].ringPos, elevatorIndex);
  });

  test('after leaving the shaft the next 7-12 goes down again', () {
    final game = Game(random: _FixedDice([5, 6, 1, 2, 1, 2, 5, 1]));
    game.players[0]
      ..ringPos = elevatorIndex
      ..shaftPos = 4;
    game.roll(); // prize + 11 -> elevator
    expect(game.players[0].inShaft, isFalse);
    for (var i = 0; i < 2; i++) {
      game.roll();
      game.skip();
    }
    game.roll(); // 5 + 1 = 6 -> along the ring
    expect(game.players[0].cell.name, 'BANK');

    final again = Game(random: _FixedDice([5, 6, 1, 2, 1, 2, 4, 3]));
    again.players[0]
      ..ringPos = elevatorIndex
      ..shaftPos = 4;
    again.roll();
    for (var i = 0; i < 2; i++) {
      again.roll();
      again.skip();
    }
    again.roll(); // 4 + 3 = 7 -> down
    expect(again.players[0].cell.name, 'Donald');
  });

  test('a double gives the same player another roll', () {
    final game = Game(random: _FixedDice([1, 1, 1, 2]));
    game.roll();
    game.skip();
    expect(game.current, 0);
    expect(game.phase, Phase.roll);
    game.roll();
    game.skip();
    expect(game.current, 1);
  });

  test('a double onto the elevator rolls again from it', () {
    final game = Game(random: _FixedDice([3, 3, 4, 4]));
    game.roll();
    expect(game.current, 0);
    game.roll();
    expect(game.players[0].cell.name, 'TipTop');
  });

  test('treasure pays 300 000', () {
    final game = Game(random: _FixedDice([1, 2]));
    game.players[0].ringPos = 35;
    game.roll();
    expect(game.players[0].cell.kind, CellKind.treasure);
    expect(game.players[0].balance, 350000);
  });

  test('passing Start pays a bonus', () {
    final game = Game(random: _FixedDice([2, 3]));
    game.players[0].ringPos = 35;
    game.roll();
    expect(game.players[0].cell.name, 'Puma');
    expect(game.players[0].balance, 70000);
  });

  test('landing on Start pays the bonus too', () {
    final game = Game(random: _FixedDice([1, 3]));
    game.players[0].ringPos = 35;
    game.roll();
    expect(game.players[0].ringPos, 0);
    expect(game.players[0].balance, 70000);
  });

  test('crisis takes 20% of cash', () {
    final game = Game(random: _FixedDice([1, 2]));
    game.players[0].ringPos = 17;
    game.roll();
    expect(game.players[0].cell.kind, CellKind.crisis);
    expect(game.players[0].balance, 40000);
  });

  test('bankrupt player drops out and loses firms', () {
    final game = Game(random: _FixedDice([3, 4, 1, 2]));
    game.owners[3] = 0;
    game.owners[1] = 1;
    game.players[1].balance = 300;
    game.roll();
    game.roll();
    expect(game.players[1].bankrupt, isTrue);
    expect(game.players[0].balance, 60300);
    expect(game.owners.containsKey(1), isFalse);
    expect(game.current, 2);
  });

  test('last player standing wins', () {
    final game = Game(names: ['A', 'B'], random: _FixedDice([3, 4, 1, 2]));
    game.owners[3] = 0;
    game.players[1].balance = 0;
    game.roll();
    game.roll();
    expect(game.phase, Phase.gameOver);
    expect(game.winner!.name, 'A');
  });
}
