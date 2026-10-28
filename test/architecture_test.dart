import 'package:flutter_test/flutter_test.dart';

import '../tool/architecture.dart';

void main() {
  final files = scanLib();

  test('every lib file belongs to a known layer', () {
    expect(files, isNotEmpty);
    for (final f in files) {
      expect(allowedLayers.keys, contains(f.layer), reason: f.path);
    }
  });

  test('layers import only what they are allowed to', () {
    expect(violations(files), isEmpty);
  });

  test('the rules catch a model file that imports ui', () {
    final bad = SourceFile('lib/model/x.dart', 1, [
      '../ui/board_view.dart',
      'package:flutter/material.dart',
    ]);
    expect(violations([bad]).map((v) => v.rule), ['layers', 'packages']);
  });
}
