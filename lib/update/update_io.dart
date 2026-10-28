import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'release.dart';

const _latest =
    'https://api.github.com/repos/DeemMoor/millionaire/releases/latest';

const updatesSupported = true;

/// The latest release if it is newer than this build, otherwise null.
Future<Release?> checkForUpdate() async {
  final res = await http.get(
    Uri.parse(_latest),
    headers: {'Accept': 'application/vnd.github+json'},
  );
  // No releases yet.
  if (res.statusCode == 404) return null;
  if (res.statusCode != 200) {
    throw HttpException('GitHub ответил ${res.statusCode}');
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final version = (json['tag_name'] as String).replaceFirst(RegExp('^v'), '');
  final current = (await PackageInfo.fromPlatform()).version;
  if (!isNewer(version, current)) return null;
  final assets = (json['assets'] as List).cast<Map<String, dynamic>>();
  String? asset(bool Function(String name) match) => assets
      .where((a) => match(a['name'] as String))
      .map((a) => a['browser_download_url'] as String)
      .firstOrNull;
  return Release(
    version: version,
    notes: json['body'] as String? ?? '',
    page: json['html_url'] as String,
    installer: Platform.isWindows
        ? asset((n) => n.endsWith('-windows-setup.exe'))
        : Platform.isAndroid
        ? asset((n) => n.endsWith('.apk'))
        : null,
    checksums: asset((n) => n == 'SHA256SUMS.txt'),
  );
}

/// Windows: download, verify against SHA256SUMS.txt, run the installer
/// silently and quit; the installer starts the new version.
/// Android: hand the APK to the system. Elsewhere: open the release page.
Future<void> install(Release r) async {
  final url = r.installer;
  if (url == null || Platform.isAndroid) {
    await launchUrl(
      Uri.parse(url ?? r.page),
      mode: LaunchMode.externalApplication,
    );
    return;
  }
  final name = url.split('/').last;
  final listing = r.checksums;
  if (listing == null) throw StateError('в релизе нет SHA256SUMS.txt');
  final expected = checksumFor(await http.read(Uri.parse(listing)), name);
  if (expected == null) throw StateError('$name нет в SHA256SUMS.txt');

  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}$name',
  );
  final response = await http.Client().send(
    http.Request('GET', Uri.parse(url)),
  );
  if (response.statusCode != 200) {
    throw HttpException('загрузка не удалась: ${response.statusCode}');
  }
  await response.stream.pipe(file.openWrite());
  final actual = (await sha256.bind(file.openRead()).first).toString();
  if (actual != expected) {
    await file.delete();
    throw StateError(
      'контрольная сумма не совпала, файл повреждён или подменён',
    );
  }
  await Process.start(file.path, [
    '/VERYSILENT',
    '/SUPPRESSMSGBOXES',
    '/NORESTART',
  ], mode: ProcessStartMode.detached);
  exit(0);
}
