/// A GitHub release newer than the running build.
class Release {
  Release({
    required this.version,
    required this.notes,
    required this.page,
    this.installer,
    this.checksums,
  });

  final String version;

  /// The release description, i.e. this version's CHANGELOG section.
  final String notes;
  final String page;

  /// The file this platform can install by itself, if any.
  final String? installer;
  final String? checksums;

  bool get selfInstalls => installer != null;
}

/// Compares the X.Y.Z parts of two versions; build numbers are ignored.
bool isNewer(String candidate, String current) {
  List<int> parts(String v) => v
      .split(RegExp(r'[.+-]'))
      .take(3)
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
  final a = parts(candidate), b = parts(current);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Finds the hash for [fileName] in a `sha256sum` listing.
String? checksumFor(String listing, String fileName) => listing
    .split('\n')
    .map((line) => line.trim().split(RegExp(r'\s+')))
    .where((p) => p.length == 2 && p[1].replaceFirst('*', '') == fileName)
    .map((p) => p[0].toLowerCase())
    .firstOrNull;
