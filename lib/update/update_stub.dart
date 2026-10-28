import 'release.dart';

/// The web build always runs the latest version: nothing to check.
const updatesSupported = false;

Future<Release?> checkForUpdate() async => null;

Future<void> install(Release release) async {}
