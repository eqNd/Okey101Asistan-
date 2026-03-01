// lib/engine/set_finder.dart
// Per: Aynı sayı, farklı renk, minimum 3 taş
import 'models/tile.dart';
import 'models/analysis_result.dart';

class SetFinder {
  List<TileGroup> findAll(List<Tile> regulars, List<Tile> jokers) {
    final results = <TileGroup>[];
    
    // Sayıya göre grupla
    final byNumber = <int, List<Tile>>{};
    for (final t in regulars) {
      byNumber.putIfAbsent(t.number, () => []).add(t);
    }

    for (final entry in byNumber.entries) {
      final group = entry.value;
      final uniqueColors = group.map((t) => t.color).toSet();

      if (uniqueColors.length >= 3) {
        // Geçerli per (joker olmadan)
        final selected = uniqueColors.map((c) => group.firstWhere((t) => t.color == c)).toList();
        if (selected.length >= 3) {
          results.add(TileGroup(tiles: selected.take(4).toList(), type: GroupType.set));
        }
      } else if (uniqueColors.length == 2 && jokers.isNotEmpty) {
        // Jokerle tamamlanabilir per
        final selected = uniqueColors.map((c) => group.firstWhere((t) => t.color == c)).toList();
        results.add(TileGroup(tiles: selected, type: GroupType.set, usesJoker: true));
      }
    }

    return results;
  }
}
