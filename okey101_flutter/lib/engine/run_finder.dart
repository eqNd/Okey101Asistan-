// lib/engine/run_finder.dart
// Seri: Aynı renk, ardışık sayı, minimum 3 taş
import 'models/tile.dart';
import 'models/analysis_result.dart';

class RunFinder {
  List<TileGroup> findAll(List<Tile> regulars, List<Tile> jokers) {
    final results = <TileGroup>[];

    final byColor = <TileColor, List<Tile>>{};
    for (final t in regulars) {
      byColor.putIfAbsent(t.color, () => []).add(t);
    }

    for (final entry in byColor.entries) {
      final sorted = [...entry.value]..sort((a, b) => a.number.compareTo(b.number));
      _extractRuns(sorted, results, jokers);
    }

    return results;
  }

  void _extractRuns(List<Tile> sorted, List<TileGroup> results, List<Tile> jokers) {
    if (sorted.isEmpty) return;

    List<Tile> current = [sorted[0]];

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].number - current.last.number;
      if (diff == 1) {
        current.add(sorted[i]);
      } else if (diff == 2 && jokers.isNotEmpty) {
        // Joker ile boşluğu doldur
        current.add(jokers.first.copyWith(isJoker: true));
        current.add(sorted[i]);
      } else {
        if (current.length >= 3) {
          results.add(TileGroup(tiles: List.from(current), type: GroupType.run));
        }
        current = [sorted[i]];
      }
    }

    if (current.length >= 3) {
      results.add(TileGroup(tiles: List.from(current), type: GroupType.run));
    }

    // Joker ile seri başı/sonu tamamla
    if (current.length == 2 && jokers.isNotEmpty) {
      // Başa joker ekle
      if (current.first.number > 1) {
        results.add(TileGroup(
          tiles: [jokers.first.copyWith(isJoker: true), ...current],
          type: GroupType.run,
          usesJoker: true,
        ));
      }
    }
  }
}
