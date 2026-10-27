import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'board.dart';
import 'money.dart';

enum Phase { roll, elevator, buy, gameOver }

const playerColors = [Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047)];

class Player {
  Player(this.name, this.color, this.balance);

  final String name;
  final Color color;
  int balance;
  int ringPos = 0;

  /// Index in [shaftCells] while stuck in the elevator shaft, null on the ring.
  int? shaftPos;
  bool bankrupt = false;

  bool get inShaft => shaftPos != null;
  BoardCell get cell => inShaft ? shaftCells[shaftPos!] : ringCells[ringPos];
}

class Game extends ChangeNotifier {
  Game({
    List<String> names = const ['Игрок 1', 'Игрок 2', 'Игрок 3'],
    this.startBalance = 50000,
    Random? random,
  })  : _random = random ?? Random(),
        players = [
          for (var i = 0; i < names.length; i++)
            Player(names[i], playerColors[i % playerColors.length], startBalance),
        ];

  static const rentRate = 0.1;

  /// Rent multiplier when the owner holds every firm of the group.
  static const groupRentMultiplier = 2;

  /// Share of cash lost on the CRISIS cell.
  static const crisisRate = 0.2;

  final int startBalance;
  final Random _random;
  final List<Player> players;

  /// Firm number -> index of the owning player.
  final Map<int, int> owners = {};
  final List<String> log = [];
  int current = 0;
  Phase phase = Phase.roll;
  List<int> dice = [1, 1];

  /// Set by a double on the main roll: the same player rolls again.
  bool _extraRoll = false;

  Player get currentPlayer => players[current];
  Player? get winner =>
      phase == Phase.gameOver ? players.firstWhere((p) => !p.bankrupt) : null;

  Player? ownerOf(BoardCell firm) {
    final index = owners[firm.number];
    return index == null ? null : players[index];
  }

  List<BoardCell> firmsOf(Player player) => [
        for (final entry in owners.entries)
          if (players[entry.value] == player) firmsByNumber[entry.key]!,
      ]..sort((a, b) => a.number!.compareTo(b.number!));

  int rentFor(BoardCell firm) {
    var rent = (firm.amount * rentRate).round();
    final owner = owners[firm.number];
    if (owner != null && _ownsWholeGroup(owner, firm.group!)) {
      rent *= groupRentMultiplier;
    }
    return rent;
  }

  bool _ownsWholeGroup(int player, FirmGroup group) {
    final firms = firmsByNumber.values.where((f) => f.group == group).toList();
    return firms.length > 1 && firms.every((f) => owners[f.number] == player);
  }

  int _die() => _random.nextInt(6) + 1;

  void roll() {
    if (phase != Phase.roll) return;
    dice = [_die(), _die()];
    _extraRoll = dice[0] == dice[1];
    final steps = dice[0] + dice[1];
    final player = currentPlayer;
    if (player.inShaft) {
      player.shaftPos = (player.shaftPos! + steps) % shaftCells.length;
      if (player.shaftPos == 0) {
        player.shaftPos = null;
        log.add('${player.name}: выход из шахты');
        return _endTurn();
      }
    } else {
      final passedStart = player.ringPos + steps >= ringCells.length;
      player.ringPos = (player.ringPos + steps) % ringCells.length;
      if (passedStart) {
        final bonus = ringCells[0].amount;
        player.balance += bonus;
        log.add('${player.name}: круг пройден, +${formatMoney(bonus)}');
      }
    }
    _resolve(player);
  }

  void rollElevator() {
    if (phase != Phase.elevator) return;
    final die = _die();
    dice = [die];
    final player = currentPlayer;
    if (die >= 4) {
      player.shaftPos = 0;
      log.add('${player.name}: элеватор $die, вниз в шахту');
    } else {
      log.add('${player.name}: элеватор $die, едем дальше');
    }
    _endTurn();
  }

  void buy() {
    if (phase != Phase.buy) return;
    final player = currentPlayer;
    final firm = player.cell;
    player.balance -= firm.amount;
    owners[firm.number!] = current;
    log.add('${player.name}: покупка ${firm.name} за ${formatMoney(firm.amount)}');
    _endTurn();
  }

  void skip() {
    if (phase != Phase.buy) return;
    _endTurn();
  }

  void _resolve(Player player) {
    final cell = player.cell;
    switch (cell.kind) {
      case CellKind.firm:
        final owner = ownerOf(cell);
        if (owner == null) {
          if (player.balance >= cell.amount) {
            phase = Phase.buy;
            notifyListeners();
            return;
          }
          log.add('${player.name}: не хватает денег на ${cell.name}');
        } else if (owner != player) {
          _payRent(player, owner, cell);
        }
      case CellKind.bank || CellKind.pot || CellKind.treasure:
        player.balance += cell.amount;
        log.add('${player.name}: +${formatMoney(cell.amount)} (${cell.name})');
      case CellKind.crisis:
        final loss = (player.balance * crisisRate).round();
        player.balance -= loss;
        log.add('${player.name}: кризис, −${formatMoney(loss)}');
      case CellKind.elevator:
        phase = Phase.elevator;
        notifyListeners();
        return;
      case CellKind.start:
        break; // the bonus is paid while moving
    }
    _endTurn();
  }

  void _payRent(Player payer, Player owner, BoardCell firm) {
    final rent = rentFor(firm);
    final paid = min(rent, payer.balance);
    payer.balance -= paid;
    owner.balance += paid;
    log.add('${payer.name} → ${owner.name}: рента ${formatMoney(paid)} за ${firm.name}');
    if (paid < rent) {
      payer.bankrupt = true;
      owners.removeWhere((_, index) => players[index] == payer);
      log.add('${payer.name}: банкрот, фирмы свободны');
    }
  }

  void _endTurn() {
    final alive = players.where((p) => !p.bankrupt).toList();
    if (alive.length <= 1) {
      phase = Phase.gameOver;
      log.add('Победитель: ${alive.first.name}');
    } else {
      if (_extraRoll && !currentPlayer.bankrupt) {
        log.add('${currentPlayer.name}: дубль, ещё бросок');
      } else {
        do {
          current = (current + 1) % players.length;
        } while (players[current].bankrupt);
      }
      phase = Phase.roll;
    }
    _extraRoll = false;
    notifyListeners();
  }
}
