/// Writes the project dashboard's data to build/codemap/*.json.
///
/// Run through tool/codemap.sh, which first saves test and analyzer results.
library;

import 'dart:convert';
import 'dart:io';

import 'architecture.dart';

const _out = 'build/codemap';

void main() {
  final lib = scanLib();
  final other = [
    for (final dir in ['test', 'tool'])
      ...scanDir(dir, pattern: RegExp(r'\.(dart|py|mjs|sh)$')),
  ];

  final bad = violations(lib);
  final loops = cycles(lib);
  final commits = _commits();
  final tests = _tests();

  final touches = <String, List<Map<String, Object?>>>{};
  for (final c in commits) {
    for (final path in c['paths'] as List<String>) {
      (touches[path] ??= []).add(c);
    }
  }
  final usedBy = <String, int>{};
  for (final f in lib) {
    for (final d in f.internalDeps) {
      usedBy[d] = (usedBy[d] ?? 0) + 1;
    }
  }

  Map<String, Object?> module(SourceFile f, String layer) {
    final own = bad.where((v) => v.path == f.path).toList();
    final history = touches[f.path] ?? const [];
    return {
      'path': f.path,
      'layer': layer,
      'lines': f.lines,
      'deps': f.internalDeps.length,
      'usedBy': usedBy[f.path] ?? 0,
      'commits': history.length,
      'lastCommit': history.isEmpty ? null : history.first['hash'],
      'lastDate': history.isEmpty ? null : history.first['date'],
      'status': own.isNotEmpty
          ? 'fail'
          : f.lines > maxLines
          ? 'warn'
          : 'ok',
      'note': own.isNotEmpty
          ? own.map((v) => v.message).join('; ')
          : f.lines > maxLines
          ? 'больше $maxLines строк'
          : '',
    };
  }

  final modules = [
    for (final f in lib) module(f, f.layer),
    for (final f in other) module(f, f.path.split('/').first),
  ];

  final deps = [
    for (final f in lib)
      for (final d in f.internalDeps)
        {
          'from': f.path,
          'to': d,
          'fromLayer': f.layer,
          'toLayer': layerOf(d),
          'status': allowedLayers[f.layer]!.contains(layerOf(d))
              ? 'ok'
              : 'fail',
        },
  ];

  final big = lib.where((f) => f.lines > maxLines).toList();
  final failed = tests.where((t) => t['result'] != 'success').length;
  final analyze = _analyze();
  final checks = [
    {
      'id': 'layers',
      'title': 'Слои',
      'status': bad.isEmpty ? 'ok' : 'fail',
      'count': bad.length,
      'detail': bad.isEmpty
          ? 'model, ui и update зависят только от разрешённых слоёв'
          : bad.join('; '),
    },
    {
      'id': 'tests',
      'title': 'Тесты',
      'status': tests.isEmpty
          ? 'warn'
          : failed == 0
          ? 'ok'
          : 'fail',
      'count': failed,
      'detail': tests.isEmpty
          ? 'нет результатов прогона'
          : '${tests.length - failed} из ${tests.length} прошли',
    },
    {
      'id': 'analyze',
      'title': 'Анализатор',
      'status': analyze == null
          ? 'warn'
          : analyze == 0
          ? 'ok'
          : 'fail',
      'count': analyze ?? 0,
      'detail': analyze == null
          ? 'нет результатов flutter analyze'
          : analyze == 0
          ? 'замечаний нет'
          : 'замечаний: $analyze',
    },
    {
      'id': 'cycles',
      'title': 'Циклы',
      'status': loops.isEmpty ? 'ok' : 'warn',
      'count': loops.length,
      'detail': loops.isEmpty
          ? 'файлы не импортируют друг друга по кругу'
          : loops
                .map((l) => [...l, l.first].map(_short).join(' > '))
                .join('; '),
    },
    {
      'id': 'size',
      'title': 'Размер файлов',
      'status': big.isEmpty ? 'ok' : 'warn',
      'count': big.length,
      'detail': big.isEmpty
          ? 'все файлы короче $maxLines строк'
          : big.map((f) => '${_short(f.path)}: ${f.lines}').join('; '),
    },
  ];

  Directory(_out).createSync(recursive: true);
  void write(String name, Object rows) =>
      File('$_out/$name.json')
          .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(rows));
  write('modules', modules);
  write('deps', deps);
  write('checks', checks);
  write('tests', tests);
  write('commits', [
    for (final c in commits) {...c}..remove('paths'),
  ]);
  stdout.writeln(
    'codemap: ${modules.length} files, ${deps.length} deps, '
    '${commits.length} commits, ${tests.length} tests, '
    '${bad.length} violations',
  );
}

String _short(String path) => path.split('/').last;

List<Map<String, Object?>> _commits() {
  final log =
      Process.runSync('git', [
            'log',
            '--numstat',
            '--date=iso-strict',
            '--format=@@%h|%ad|%s',
          ]).stdout
          as String;
  final result = <Map<String, Object?>>[];
  for (final block in log.split('@@').where((b) => b.trim().isNotEmpty)) {
    final lines = block.trim().split('\n');
    final [hash, date, ...subject] = lines.first.split('|');
    var added = 0, removed = 0;
    final paths = <String>[];
    for (final l in lines.skip(1).where((l) => l.trim().isNotEmpty)) {
      final [a, r, path] = l.split('\t');
      added += int.tryParse(a) ?? 0;
      removed += int.tryParse(r) ?? 0;
      paths.add(path);
    }
    final layers = {
      for (final p in paths)
        if (p.startsWith('lib/'))
          layerOf(p)
        else if (p.contains('/'))
          p.split('/').first
        else
          'root',
    }.toList()..sort();
    result.add({
      'hash': hash,
      'date': date,
      'message': subject.join('|'),
      'files': paths.length,
      'added': added,
      'removed': removed,
      'layers': layers.join(', '),
      'paths': paths,
    });
  }
  return result;
}

/// Parses `flutter test --machine` output saved by tool/codemap.sh.
List<Map<String, Object?>> _tests() {
  final file = File('$_out/test-events.jsonl');
  if (!file.existsSync()) return [];
  final suites = <int, String>{};
  final started = <int, Map<String, dynamic>>{};
  final result = <Map<String, Object?>>[];
  for (final line in file.readAsLinesSync()) {
    if (!line.startsWith('{')) continue;
    final e = jsonDecode(line) as Map<String, dynamic>;
    switch (e['type']) {
      case 'suite':
        final s = e['suite'] as Map<String, dynamic>;
        suites[s['id'] as int] = s['path'] as String;
      case 'testStart':
        final t = e['test'] as Map<String, dynamic>;
        started[t['id'] as int] = {...t, 'time': e['time']};
      case 'testDone' when e['hidden'] != true:
        final t = started[e['testID']]!;
        final suite = suites[t['suiteID']] ?? '';
        result.add({
          'file': suite.substring(suite.indexOf('test/')),
          'name': t['name'],
          'result': e['skipped'] == true ? 'skipped' : e['result'],
          'ms': (e['time'] as int) - (t['time'] as int),
        });
    }
  }
  return result;
}

/// Issue count from `flutter analyze` output, or null if it wasn't run.
int? _analyze() {
  final file = File('$_out/analyze.txt');
  if (!file.existsSync()) return null;
  final text = file.readAsStringSync();
  if (text.contains('No issues found')) return 0;
  final m = RegExp(r'(\d+) issues? found').firstMatch(text);
  return m == null ? null : int.parse(m[1]!);
}
