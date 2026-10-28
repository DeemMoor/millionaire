import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/board.dart';
import '../model/game.dart';
import '../model/money.dart';

const _ink = Color(0xFF263238);

Color _textOn(Color background) =>
    background.computeLuminance() > 0.45 ? _ink : Colors.white;

Color _cellColor(BoardCell cell) => switch (cell.kind) {
  CellKind.firm => cell.color,
  CellKind.bank => const Color(0xFFE3F2FD),
  CellKind.start => const Color(0xFFFFFFFF),
  CellKind.treasure => const Color(0xFFFFD54F),
  CellKind.crisis => const Color(0xFFFFEBEE),
  CellKind.elevator => const Color(0xFFECEFF1),
  CellKind.pot => const Color(0xFFFFFFFF),
};

class CellView extends StatelessWidget {
  const CellView({super.key, required this.cell, this.owner});

  final BoardCell cell;
  final Player? owner;

  @override
  Widget build(BuildContext context) {
    final color = _cellColor(cell);
    final fg = _textOn(color);
    final owned = owner != null;
    final pot = cell.kind == CellKind.pot;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.3)!,
            Color.lerp(color, Colors.black, 0.08)!,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              owner?.color ??
              (pot
                  ? Colors.red.shade700
                  : Colors.black.withValues(alpha: 0.18)),
          width: owned || pot ? 3.5 : 1,
        ),
        boxShadow: [
          const BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black38,
          ),
          if (owned)
            BoxShadow(
              blurRadius: 8,
              spreadRadius: 1,
              color: owner!.color.withValues(alpha: 0.7),
            ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
      child: DefaultTextStyle(
        style: TextStyle(
          color: fg,
          fontFamily: 'PTSans',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        child: _content(fg),
      ),
    );
  }

  Widget _content(Color fg) => switch (cell.kind) {
    CellKind.firm when cell.group == FirmGroup.shaft => Column(
      children: [
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: switch (cell.emblem) {
                'turbo' => const _TurboWrapper(),
                'donald' => const _DonaldWrapper(),
                _ => const _TipiTipWrapper(),
              },
            ),
          ),
        ),
        SizedBox(height: 16, child: _Footer(cell)),
      ],
    ),
    CellKind.firm => _Card(
      emblem: cell.emblem,
      title: cell.name,
      titleColor: fg,
      footer: Row(
        children: [
          _NumberBadge(cell.number!),
          const SizedBox(width: 4),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(formatMoney(cell.amount)),
            ),
          ),
        ],
      ),
    ),
    CellKind.bank => _Card(
      emblem: cell.emblem,
      title: 'BANK',
      titleColor: Colors.blue.shade900,
      footer: _Amount('+${formatMoney(cell.amount)}', Colors.green.shade800),
    ),
    CellKind.start => _Card(
      emblem: cell.emblem,
      title: 'START',
      titleColor: Colors.blue.shade800,
      footer: _Amount('+${formatMoney(cell.amount)}', Colors.green.shade800),
    ),
    CellKind.treasure => _Card(
      emblem: cell.emblem,
      title: 'TREASURE',
      titleColor: Colors.brown.shade800,
      footer: _Amount('+${formatMoney(cell.amount)}', Colors.red.shade800),
    ),
    CellKind.crisis => _Card(
      emblem: cell.emblem,
      title: 'CRISIS',
      titleColor: Colors.red.shade700,
      footer: _Amount(
        '-${(Game.crisisRate * 100).round()}%',
        Colors.red.shade700,
      ),
    ),
    CellKind.elevator => Row(
      children: [
        const SizedBox.square(dimension: 64, child: _Medallion('elevator')),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FittedBox(
                child: Text(
                  'ЭЛЕВАТОР',
                  style: TextStyle(fontFamily: 'RussoOne', fontSize: 13),
                ),
              ),
              _ElevatorRule(
                '2–6',
                Icons.arrow_forward_rounded,
                Colors.blue.shade700,
              ),
              _ElevatorRule(
                '7–12',
                Icons.arrow_downward_rounded,
                Colors.red.shade700,
              ),
            ],
          ),
        ),
      ],
    ),
    CellKind.pot => Row(
      children: [
        const SizedBox.square(dimension: 60, child: _Medallion('pot')),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            child: Text(
              '\$ ${formatMoney(cell.amount)} \$',
              style: TextStyle(
                fontFamily: 'RussoOne',
                fontSize: 30,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ),
      ],
    ),
  };
}

class _Footer extends StatelessWidget {
  const _Footer(this.cell);

  final BoardCell cell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NumberBadge(cell.number!),
        const Spacer(),
        Text(
          formatMoney(cell.amount),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

/// Chunky yellow wordmark with a black outline and a drop shadow,
/// like on 90s bubble gum wrappers.
class _Wordmark extends StatelessWidget {
  const _Wordmark(this.text, {this.size = 28});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: 'RussoOne', fontSize: size, height: 1);
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(size * 0.07, size * 0.08),
          child: Text(
            text,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = size * 0.16
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.black,
            ),
          ),
        ),
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.1
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.black,
          ),
        ),
        Text(text, style: base.copyWith(color: const Color(0xFFFFEB3B))),
      ],
    );
  }
}

class _GumCaption extends StatelessWidget {
  const _GumCaption(this.text, {this.color = Colors.white, this.size = 9});

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PTSans',
        fontWeight: FontWeight.bold,
        fontSize: size,
        letterSpacing: 1.5,
        color: color,
        shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black54)],
      ),
    );
  }
}

class _TurboWrapper extends StatelessWidget {
  const _TurboWrapper();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _GumCaption('k·artel', color: Colors.black87, size: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: _Wordmark('Turbo', size: 30),
                ),
                Positioned(
                  right: -6,
                  top: -14,
                  child: Transform.rotate(
                    angle: 0.25,
                    child: const _CheckeredFlag(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            const _GumCaption('BUBBLE GUM'),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          color: const Color(0xFFECEFF1),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: const RotatedBox(
            quarterTurns: 3,
            child: Text(
              'STICKER',
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckeredFlag extends StatelessWidget {
  const _CheckeredFlag();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 3; r++)
            Row(
              children: [
                for (var c = 0; c < 4; c++)
                  Container(
                    width: 5,
                    height: 5,
                    color: (r + c).isEven ? Colors.black : Colors.white,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DonaldWrapper extends StatelessWidget {
  const _DonaldWrapper();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 44,
          child: SvgPicture.asset('assets/emblems/donald.svg'),
        ),
        const SizedBox(width: 2),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Wordmark('Donald', size: 26),
            SizedBox(height: 4),
            _GumCaption('BUBBLE GUM', color: Color(0xFFFFEB3B)),
          ],
        ),
      ],
    );
  }
}

class _TipiTipWrapper extends StatelessWidget {
  const _TipiTipWrapper();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 46,
          child: SvgPicture.asset('assets/emblems/tipitip.svg'),
        ),
        const SizedBox(width: 2),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GumCaption('kent', color: Color(0xFFE53935), size: 10),
            _Wordmark('TipiTip', size: 24),
            SizedBox(height: 3),
            _GumCaption('BALONLU ÇİKLET', size: 7.5),
          ],
        ),
      ],
    );
  }
}

/// Emblem on top, title and footer below.
class _Card extends StatelessWidget {
  const _Card({
    required this.emblem,
    required this.title,
    required this.titleColor,
    required this.footer,
  });

  final String emblem;
  final String title;
  final Color titleColor;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final light = titleColor.computeLuminance() > 0.5;
    return Column(
      children: [
        Expanded(child: Center(child: _Medallion(emblem))),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'RussoOne',
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: titleColor,
              shadows: light
                  ? const [Shadow(blurRadius: 2, color: Colors.black54)]
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(height: 16, child: footer),
      ],
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion(this.emblem);

  final String emblem;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.4),
            colors: [Colors.white, Color(0xFFE6EBEE)],
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 1),
              color: Colors.black26,
            ),
          ],
        ),
        child: SvgPicture.asset('assets/emblems/$emblem.svg'),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: _ink,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _ElevatorRule extends StatelessWidget {
  const _ElevatorRule(this.range, this.icon, this.color);

  final String range;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(range, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(width: 2),
          Icon(icon, size: 16, color: color),
        ],
      ),
    );
  }
}

void showCellInfo(BuildContext context, Game game, BoardCell cell) {
  final owner = cell.isFirm ? game.ownerOf(cell) : null;
  final lines = switch (cell.kind) {
    CellKind.firm => [
      'Цена: ${formatMoney(cell.amount)}',
      'Рента: ${formatMoney(game.rentFor(cell))}',
      'Владелец: ${owner?.name ?? 'свободна'}',
    ],
    CellKind.bank ||
    CellKind.treasure => ['Выдаёт ${formatMoney(cell.amount)}'],
    CellKind.start => ['За проход или попадание: +${formatMoney(cell.amount)}'],
    CellKind.crisis => ['Теряешь ${(Game.crisisRate * 100).round()}% наличных'],
    CellKind.elevator => [
      'Стоишь на элеваторе и бросаешь:',
      '2–6: дальше по кругу,',
      '7–12: вниз в шахту на столько шагов.',
      'Из шахты выход только точным попаданием на элеватор.',
    ],
    CellKind.pot => ['Приз ${formatMoney(cell.amount)} за попадание из шахты'],
  };
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: SizedBox(width: 72, height: 72, child: _Medallion(cell.emblem)),
      title: Text(
        cell.isFirm ? '${cell.number}. ${cell.name}' : cell.name,
        style: const TextStyle(fontFamily: 'RussoOne'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Text(line, style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
