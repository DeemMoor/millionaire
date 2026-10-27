import 'package:flutter/material.dart';

import '../model/game.dart';
import '../model/money.dart';

/// Replaces the old notebook: balance and owned firms per player.
class PlayersPanel extends StatelessWidget {
  const PlayersPanel({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < game.players.length; i++)
          _PlayerCard(game: game, player: game.players[i], isCurrent: i == game.current),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.game, required this.player, required this.isCurrent});

  final Game game;
  final Player player;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final firms = game.firmsOf(player);
    final worth = game.netWorth(player);
    final card = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isCurrent ? 0.18 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? player.color : Colors.transparent,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 9, backgroundColor: player.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (player.inShaft)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text('шахта', style: TextStyle(color: Colors.amber)),
                ),
              Text(
                formatMoney(player.balance),
                style: const TextStyle(
                  color: Color(0xFFFFEB3B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (player.bankrupt) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'БАНКРОТ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              player.bankruptReason ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (worth / Game.winTarget).clamp(0, 1).toDouble(),
                      minHeight: 6,
                      color: const Color(0xFFFFEB3B),
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'капитал ${formatMoney(worth)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (player.bankrupt)
            const SizedBox.shrink()
          else if (firms.isEmpty)
            const Text('нет фирм', style: TextStyle(color: Colors.white38))
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final firm in firms)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: firm.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      firm.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: firm.color.computeLuminance() > 0.45
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
    return player.bankrupt ? Opacity(opacity: 0.55, child: card) : card;
  }
}
