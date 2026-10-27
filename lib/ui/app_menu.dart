import 'dart:ui' show AppExitType;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/board.dart';
import '../model/game.dart';
import '../model/money.dart';

const _newGameKey = SingleActivator(LogicalKeyboardKey.f2);
const _exitKey = SingleActivator(LogicalKeyboardKey.keyX, alt: true);
const _helpKey = SingleActivator(LogicalKeyboardKey.f1);

/// Classic "Файл / Справка" menu bar with hotkeys, above [child].
class AppMenu extends StatelessWidget {
  const AppMenu({super.key, required this.child, this.onNewGame});

  final Widget child;

  /// Null disables "Новая игра" (e.g. on the setup screen).
  final VoidCallback? onNewGame;

  // A browser tab can't be closed by the page, so there is no exit on the web.
  static const _canExit = !kIsWeb;

  void _exit() =>
      ServicesBinding.instance.exitApplication(AppExitType.required);

  @override
  Widget build(BuildContext context) {
    void help() => _showHelp(context);
    return CallbackShortcuts(
      bindings: {
        _newGameKey: ?onNewGame,
        if (_canExit) _exitKey: _exit,
        _helpKey: help,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MenuBar(
                    style: const MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xCC042E2E),
                      ),
                      elevation: WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                    children: [
                      _Submenu(
                        label: 'Файл',
                        children: [
                          MenuItemButton(
                            shortcut: _newGameKey,
                            onPressed: onNewGame,
                            leadingIcon: const Icon(Icons.casino_outlined),
                            child: const Text('Новая игра'),
                          ),
                          if (_canExit) ...[
                            const Divider(height: 1),
                            MenuItemButton(
                              shortcut: _exitKey,
                              onPressed: _exit,
                              leadingIcon: const Icon(Icons.logout),
                              child: const Text('Выход'),
                            ),
                          ],
                        ],
                      ),
                      _Submenu(
                        label: 'Справка',
                        children: [
                          MenuItemButton(
                            onPressed: () => _showAbout(context),
                            leadingIcon: const Icon(Icons.info_outline),
                            child: const Text('О программе'),
                          ),
                          MenuItemButton(
                            shortcut: _helpKey,
                            onPressed: help,
                            leadingIcon: const Icon(Icons.help_outline),
                            child: const Text('Помощь'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _Submenu extends StatelessWidget {
  const _Submenu({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SubmenuButton(
      style: SubmenuButton.styleFrom(foregroundColor: Colors.white),
      menuChildren: children,
      child: Text(label),
    );
  }
}

void _showAbout(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Миллионер',
    applicationVersion: 'версия 2.0',
    applicationIcon: SizedBox.square(
      dimension: 56,
      child: SvgPicture.asset('assets/emblems/pot.svg'),
    ),
    applicationLegalese: 'Ремейк игры «Миллионер 1.0» 2001 года.\n© DeemMoor',
  );
}

void _showHelp(BuildContext context) {
  const heading = TextStyle(fontFamily: 'RussoOne', fontSize: 16);
  Widget rule(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
  final rent = (Game.rentRate * 100).round();
  final crisis = (Game.crisisRate * 100).round();
  int amountOf(CellKind kind) =>
      ringCells.firstWhere((c) => c.kind == kind).amount;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Помощь', style: TextStyle(fontFamily: 'RussoOne')),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ход', style: heading),
                const SizedBox(height: 6),
                rule(
                  'Игроки по очереди бросают два кубика и ходят фишками по кругу.',
                ),
                rule('Дубль — ещё один бросок.'),
                rule(
                  'Проход или попадание на START: +${formatMoney(amountOf(CellKind.start))}.',
                ),
                const SizedBox(height: 8),
                const Text('Фирмы', style: heading),
                const SizedBox(height: 6),
                rule('Свободную фирму можно купить по цене на клетке.'),
                rule(
                  'На чужой фирме платишь ренту: $rent% цены, ×${Game.groupRentMultiplier} '
                  'если у владельца собрана вся группа.',
                ),
                rule(
                  'Не хватает денег на ренту — фирмы продаются банку за полцены, '
                  'начиная с дешёвых. Не хватило и после этого — банкрот.',
                ),
                const SizedBox(height: 8),
                const Text('Особые клетки', style: heading),
                const SizedBox(height: 6),
                rule(
                  'BANK выдаёт сумму, написанную на клетке. TREASURE: +${formatMoney(amountOf(CellKind.treasure))}.',
                ),
                rule('CRISIS: теряешь $crisis% наличных.'),
                rule(
                  'Элеватор: стоишь на нём — следующий бросок 2–6 ведёт дальше по кругу, '
                  '7–12 — вниз в шахту: Turbo, Donald, Tipi Tip и приз ${formatMoney(shaftCells.last.amount)}, затем снова элеватор. '
                  'Из шахты выход только точным попаданием на элеватор.',
                ),
                const SizedBox(height: 8),
                const Text('Победа', style: heading),
                const SizedBox(height: 6),
                rule(
                  'Побеждает первый, чей капитал (наличные + цены фирм) дошёл до '
                  '${formatMoney(Game.winTarget)}, или последний оставшийся.',
                ),
                const SizedBox(height: 8),
                const Text('Клавиши', style: heading),
                const SizedBox(height: 6),
                rule(
                  'F2 — новая игра, F1 — помощь${AppMenu._canExit ? ', Alt+X — выход' : ''}.',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}
