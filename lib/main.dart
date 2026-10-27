import 'package:flutter/material.dart';

import 'ui/game_screen.dart';

void main() => runApp(const MillionaireApp());

class MillionaireApp extends StatelessWidget {
  const MillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Миллионер',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const GameScreen(),
    );
  }
}
