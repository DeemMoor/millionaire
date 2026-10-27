import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:millionaire/model/board.dart';

void main() {
  test('every cell has an emblem asset', () {
    for (final cell in {...ringCells, ...shaftCells}) {
      expect(File('assets/emblems/${cell.emblem}.svg').existsSync(), isTrue,
          reason: cell.name);
    }
  });
}
