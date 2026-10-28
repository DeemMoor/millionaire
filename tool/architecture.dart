/// Layer rules for lib/ and a scanner that checks the code against them.
///
/// Used by test/architecture_test.dart (CI fails on a violation) and by
/// tool/codemap.dart (the project dashboard).
library;

import 'dart:io';

/// Which layers each layer may import.
const allowedLayers = {
  'app': {'app', 'ui', 'update', 'model'},
  'ui': {'ui', 'model', 'update'},
  'model': {'model'},
  'update': {'update'},
};

/// External imports a layer may not use, with the reason shown on a violation.
const forbiddenPackages = {
  'model': {
    'package:flutter/material.dart': 'модель не знает про виджеты',
    'package:flutter/widgets.dart': 'модель не знает про виджеты',
    'package:flutter/services.dart': 'модель не знает про платформу',
    'package:shared_preferences/': 'модель ничего не хранит',
    'package:http/': 'модель не ходит в сеть',
    'dart:io': 'модель не трогает файлы и сеть',
  },
  'ui': {
    'package:http/': 'в сеть ходит только update',
    'dart:io': 'файлы и процессы — только в update',
  },
  'update': {
    'package:flutter/material.dart': 'update без виджетов, диалоги рисует ui',
    'package:flutter/widgets.dart': 'update без виджетов, диалоги рисует ui',
  },
};

/// Files longer than this get a warning: time to split.
const maxLines = 400;

String layerOf(String path) {
  if (path == 'lib/main.dart') return 'app';
  final parts = path.split('/');
  return parts.length > 2 ? parts[1] : 'app';
}

class SourceFile {
  SourceFile(this.path, this.lines, this.imports);

  final String path;
  final int lines;

  /// Raw import/export URIs as written.
  final List<String> imports;

  String get layer => layerOf(path);

  /// Imports resolved to lib/ paths (internal dependencies only).
  List<String> get internalDeps => [for (final uri in imports) ?_resolve(uri)];

  String? _resolve(String uri) {
    if (uri.startsWith('package:millionaire/')) {
      return 'lib/${uri.substring('package:millionaire/'.length)}';
    }
    if (uri.contains(':')) return null;
    final dir = path.substring(0, path.lastIndexOf('/'));
    return Uri.parse('$dir/').resolve(uri).path;
  }
}

class Violation {
  Violation(this.path, this.rule, this.message);

  final String path;
  final String rule;
  final String message;

  @override
  String toString() => '$path: $message';
}

final _importRe = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
final _conditionalRe = RegExp(r'''\bif\s*\([^)]*\)\s*['"]([^'"]+)['"]''');

SourceFile readSource(File file, String root) {
  final path = file.path.substring(root.length + 1).replaceAll('\\', '/');
  final text = file.readAsLinesSync();
  final imports = <String>[];
  for (final line in text) {
    final m = _importRe.firstMatch(line);
    if (m == null) continue;
    imports.add(m[1]!);
    imports.addAll(_conditionalRe.allMatches(line).map((c) => c[1]!));
  }
  return SourceFile(path, text.length, imports);
}

List<SourceFile> scanLib([String root = '.']) => scanDir('lib', root: root);

/// Source files under [dir] whose names match [pattern], sorted by path.
List<SourceFile> scanDir(
  String dir, {
  String root = '.',
  Pattern pattern = '.dart',
}) {
  final rootPath = Directory(root).absolute.path
      .replaceAll(RegExp(r'/\.?$'), '');
  return [
    for (final f in Directory('$rootPath/$dir').listSync(recursive: true))
      if (f is File && f.path.contains(pattern)) readSource(f, rootPath),
  ]..sort((a, b) => a.path.compareTo(b.path));
}

/// Layer and package violations. These fail the build.
List<Violation> violations(List<SourceFile> files) => [
  for (final f in files) ...[
    for (final dep in f.internalDeps)
      if (!allowedLayers[f.layer]!.contains(layerOf(dep)))
        Violation(
          f.path,
          'layers',
          '${f.layer} не должен зависеть от ${layerOf(dep)} ($dep)',
        ),
    for (final uri in f.imports)
      for (final MapEntry(key: prefix, value: why)
          in (forbiddenPackages[f.layer] ?? const {}).entries)
        if (uri.startsWith(prefix)) Violation(f.path, 'packages', '$uri: $why'),
  ],
];

/// Files that import each other in a loop, as a list of cycles.
List<List<String>> cycles(List<SourceFile> files) {
  final graph = {for (final f in files) f.path: f.internalDeps};
  final found = <String>{};
  final result = <List<String>>[];
  void walk(String node, List<String> stack) {
    final at = stack.indexOf(node);
    if (at >= 0) {
      final loop = stack.sublist(at);
      final key = ([...loop]..sort()).join();
      if (found.add(key)) result.add(loop);
      return;
    }
    for (final next in graph[node] ?? const <String>[]) {
      walk(next, [...stack, node]);
    }
  }

  for (final node in graph.keys) {
    walk(node, []);
  }
  return result;
}
