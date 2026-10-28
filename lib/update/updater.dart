import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'release.dart';
import 'update.dart' as update;

const _checkedAtKey = 'update_checked_at';

/// The update found by the last check, shared by every screen's menu.
final availableUpdate = ValueNotifier<Release?>(null);

/// Checks GitHub at most once a day; failures are silent.
Future<void> autoCheckForUpdate() async {
  if (!update.updatesSupported) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    final last = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(_checkedAtKey) ?? 0,
    );
    if (DateTime.now().difference(last) < const Duration(days: 1)) return;
    availableUpdate.value = await update.checkForUpdate();
    await prefs.setInt(_checkedAtKey, DateTime.now().millisecondsSinceEpoch);
  } catch (_) {
    // Offline or GitHub is unreachable: try again on the next start.
  }
}

/// Manual check from the menu; errors are reported to the caller.
Future<Release?> checkForUpdateNow() async {
  final release = await update.checkForUpdate();
  availableUpdate.value = release;
  return release;
}
