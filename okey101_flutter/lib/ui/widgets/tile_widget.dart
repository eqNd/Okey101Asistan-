// lib/ui/widgets/tile_widget.dart
import 'package:flutter/material.dart';
import '../../engine/models/tile.dart';
import '../../core/theme.dart';

enum TileState { normal, highlighted, weak, paired, selected }

class TileWidget extends StatelessWidget {
  final Tile tile;
  final TileState state;
  final VoidCallback? onTap;
  final double size;

  const TileWidget({
    super.key,
    required this.tile,
    this.state = TileState.normal,
    this.onTap,
    this.size = 1.0,
  });

  Color get _tileColor {
    if (tile.isJoker) return AppTheme.accent3;
    return switch (tile.color) {
      TileColor.red => AppTheme.tileRed,
      TileColor.blue => AppTheme.tileBlue,
      TileColor.yellow => AppTheme.tileYellow,
      TileColor.black => AppTheme.tileBlack,
    };
  }

  Color get _borderColor => switch (state) {
    TileState.highlighted => AppTheme.green,
    TileState.weak => AppTheme.accent,
    TileState.paired => AppTheme.accent2,
    TileState.selected => AppTheme.accent3,
    _ => tile.isJoker ? AppTheme.accent3 : AppTheme.border,
  };

  Color get _glowColor => switch (state) {
    TileState.highlighted => AppTheme.green.withOpacity(0.4),
    TileState.weak => AppTheme.accent.withOpacity(0.4),
    TileState.paired => AppTheme.accent2.withOpacity(0.4),
    _ => Colors.transparent,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 38 * size,
        height: 50 * size,
        decoration: BoxDecoration(
          color: tile.isJoker
              ? AppTheme.accent3.withOpacity(0.1)
              : const Color(0xFF1A2235),
          borderRadius: BorderRadius.circular(7 * size),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: state != TileState.normal
              ? [BoxShadow(color: _glowColor, blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tile.isJoker ? '★' : '${tile.number}',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 15 * size,
                fontWeight: FontWeight.w700,
                color: _tileColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 5 * size,
              height: 5 * size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tileColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Taş ızgarası (satır halinde, yatay scroll)
class TileRow extends StatelessWidget {
  final List<Tile> tiles;
  final Map<int, TileState> states;
  final Function(int)? onTileTap;

  const TileRow({
    super.key,
    required this.tiles,
    this.states = const {},
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tiles.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TileWidget(
              tile: e.value,
              state: states[e.key] ?? TileState.normal,
              onTap: onTileTap != null ? () => onTileTap!(e.key) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
