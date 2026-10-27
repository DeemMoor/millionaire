import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/game.dart';
import 'app_menu.dart';
import 'game_screen.dart';

const _namesKey = 'player_names';
const _defaultNames = ['Игрок 1', 'Игрок 2', 'Игрок 3'];

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _controllers = [
    for (final name in _defaultNames) TextEditingController(text: name),
  ];

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadNames() async {
    final saved = (await SharedPreferences.getInstance()).getStringList(
      _namesKey,
    );
    if (saved == null || saved.length != _controllers.length || !mounted) {
      return;
    }
    for (var i = 0; i < saved.length; i++) {
      _controllers[i].text = saved[i];
    }
  }

  Future<void> _start() async {
    final names = [
      for (var i = 0; i < _controllers.length; i++)
        _controllers[i].text.trim().isEmpty
            ? _defaultNames[i]
            : _controllers[i].text.trim(),
    ];
    await (await SharedPreferences.getInstance()).setStringList(
      _namesKey,
      names,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => GameScreen(names: names)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5C5C),
      body: AppMenu(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '\$ Миллионер \$',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFEB3B),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (var i = 0; i < _controllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _controllers[i],
                        maxLength: 16,
                        textInputAction: i == _controllers.length - 1
                            ? TextInputAction.done
                            : TextInputAction.next,
                        onSubmitted: i == _controllers.length - 1
                            ? (_) => _start()
                            : null,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          prefixIcon: Icon(
                            Icons.circle,
                            color: playerColors[i],
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _start,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                    ),
                    child: const Text(
                      'Начать игру',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
