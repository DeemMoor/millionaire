import 'package:flutter/painting.dart';

enum CellKind { start, firm, bank, elevator, crisis, treasure, pot }

enum FirmGroup { sport, moto, auto, electronics, band, drinks, shaft }

class BoardCell {
  const BoardCell({
    required this.kind,
    required this.name,
    this.number,
    this.amount = 0,
    this.group,
    this.color = const Color(0xFFFFFFFF),
  });

  final CellKind kind;
  final String name;

  /// Firm number as printed on the board (1..33), null for special cells.
  final int? number;

  /// Firm price, bank payout or prize, depending on [kind].
  final int amount;
  final FirmGroup? group;
  final Color color;

  bool get isFirm => kind == CellKind.firm;

  /// Asset name in assets/emblems/ (see tool/emblems.py).
  String get emblem =>
      isFirm ? name.toLowerCase().replaceAll(' ', '') : kind.name;
}

BoardCell _firm(
  int number,
  String name,
  int price,
  FirmGroup group,
  int color,
) => BoardCell(
  kind: CellKind.firm,
  name: name,
  number: number,
  amount: price,
  group: group,
  color: Color(color),
);

BoardCell _bank(int amount) =>
    BoardCell(kind: CellKind.bank, name: 'BANK', amount: amount);

const elevatorIndex = 6;

/// The outer ring, clockwise from Start (top-left corner).
final ringCells = <BoardCell>[
  // Paid for passing or landing on Start.
  const BoardCell(kind: CellKind.start, name: 'Start', amount: 20000),
  _firm(1, 'Puma', 10000, FirmGroup.sport, 0xFFEF5350),
  _firm(2, 'Montana', 10000, FirmGroup.sport, 0xFFFF9800),
  _firm(3, 'Adidas', 10000, FirmGroup.sport, 0xFFFFF59D),
  _firm(4, 'Gold Cup', 10000, FirmGroup.sport, 0xFFD500F9),
  _firm(5, 'BotaS', 10000, FirmGroup.sport, 0xFF4CAF50),
  const BoardCell(kind: CellKind.elevator, name: 'Элеватор'),
  _bank(10000),
  _firm(6, 'Suzuki', 15000, FirmGroup.moto, 0xFFD4E157),
  _firm(7, 'Yamaha', 15000, FirmGroup.moto, 0xFFDCE775),
  _firm(8, 'Honda', 15000, FirmGroup.moto, 0xFFC0CA33),
  _firm(9, 'Kawasaki', 15000, FirmGroup.moto, 0xFFE6EE9C),
  _bank(15000),
  _firm(10, 'Audi', 20000, FirmGroup.auto, 0xFF9CCC65),
  _firm(11, 'BMW', 20000, FirmGroup.auto, 0xFF81D4FA),
  _firm(12, 'Mercedes', 20000, FirmGroup.auto, 0xFFD7CCC8),
  _firm(13, 'Opel', 20000, FirmGroup.auto, 0xFFFFEE58),
  _firm(14, 'Volkswagen', 20000, FirmGroup.auto, 0xFFF8BBD0),
  _firm(15, 'Nissan', 25000, FirmGroup.auto, 0xFF4DD0E1),
  _firm(16, 'Toyota', 25000, FirmGroup.auto, 0xFFB2EBF2),
  const BoardCell(kind: CellKind.crisis, name: 'CRISIS'),
  _bank(20000),
  _firm(17, 'Canon', 10000, FirmGroup.electronics, 0xFFFFB300),
  _firm(18, 'Fisher', 10000, FirmGroup.electronics, 0xFFF48FB1),
  _firm(19, 'National', 10000, FirmGroup.electronics, 0xFFE53935),
  _firm(20, 'Philips', 10000, FirmGroup.electronics, 0xFF66BB6A),
  _firm(21, 'Sharp', 10000, FirmGroup.electronics, 0xFFFF7043),
  _firm(22, 'AYVA', 10000, FirmGroup.electronics, 0xFFFFEB3B),
  _firm(23, 'Akai', 10000, FirmGroup.electronics, 0xFFAB47BC),
  _firm(24, 'Panasonic', 10000, FirmGroup.electronics, 0xFFEC407A),
  _firm(25, 'Sanyo', 10000, FirmGroup.electronics, 0xFF7E57C2),
  _firm(26, 'Casio', 10000, FirmGroup.electronics, 0xFF43A047),
  _bank(25000),
  _firm(27, 'BAND', 85000, FirmGroup.band, 0xFFFFE0B2),
  _bank(30000),
  _firm(28, 'Pepsi', 15000, FirmGroup.drinks, 0xFFE3F2FD),
  _firm(29, 'Fanta', 15000, FirmGroup.drinks, 0xFFFFCC80),
  _firm(30, '7 UP', 15000, FirmGroup.drinks, 0xFF2E7D32),
  const BoardCell(
    kind: CellKind.treasure,
    name: 'Treasure',
    amount: 300000,
    color: Color(0xFFB2FF59),
  ),
];

/// The elevator shaft loop: elevator -> 31 -> 32 -> 33 -> prize -> elevator.
/// The only way out is landing exactly on index 0.
final shaftCells = <BoardCell>[
  ringCells[elevatorIndex],
  _firm(31, 'Turbo', 20000, FirmGroup.shaft, 0xFFB71C1C),
  _firm(32, 'Donald', 20000, FirmGroup.shaft, 0xFFE53935),
  _firm(33, 'Tipi Tip', 20000, FirmGroup.shaft, 0xFF29B6F6),
  const BoardCell(kind: CellKind.pot, name: 'Приз', amount: 15000),
];

final firmsByNumber = <int, BoardCell>{
  for (final cell in [...ringCells, ...shaftCells])
    if (cell.isFirm) cell.number!: cell,
};
