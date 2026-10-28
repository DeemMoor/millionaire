import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui/setup_screen.dart';
import 'update/updater.dart';

void main() {
  runApp(const MillionaireApp());
  autoCheckForUpdate();
}

class MillionaireApp extends StatelessWidget {
  const MillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Миллионер',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, fontFamily: 'PTSans'),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const SetupScreen(),
    );
  }
}
