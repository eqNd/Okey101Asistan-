// lib/engine/joker_resolver.dart
import 'models/tile.dart';
import 'models/analysis_result.dart';

/// Mevcut gruplarda joker'ların en verimli kullanımını belirler (Dynamic Programming)
class JokerResolver {
  List<TileGroup> resolve(List<TileGroup> groups, List<Tile> jokers) {
    if (jokers.isEmpty) return groups;

    // Joker gerektiren grupları önceliklendir (score/joker oranına göre)
    final jokered = groups.where((g) => g.usesJoker).toList();
    final plain = groups.where((g) => !g.usesJoker).toList();

    // Joker sayısı yeterliyse jokered grupları dahil et
    int availableJokers = jokers.length;
    final resolved = <TileGroup>[...plain];

    jokered.sort((a, b) => b.score.compareTo(a.score));
    for (final g in jokered) {
      if (availableJokers > 0) {
        resolved.add(g);
        availableJokers--;
      }
    }

    return resolved;
  }
}

// lib/engine/pair_evaluator.dart
class PairResult {
  final List<List<Tile>> pairs;
  final bool isPairMode;
  int get pairCount => pairs.length;

  const PairResult({required this.pairs, required this.isPairMode});
}

class PairEvaluator {
  PairResult evaluate(List<Tile> regulars, List<Tile> jokers) {
    final pairs = <List<Tile>>[];

    final byNumber = <int, List<Tile>>{};
    for (final t in regulars) {
      byNumber.putIfAbsent(t.number, () => []).add(t);
    }

    for (final group in byNumber.values) {
      if (group.length >= 2) {
        pairs.add(group.take(2).toList());
        if (group.length >= 4) pairs.add(group.skip(2).take(2).toList());
      }
    }

    // Joker ile eksik çifti tamamla
    if (jokers.isNotEmpty && pairs.length == 4) {
      final singletons = byNumber.values
          .where((g) => g.length == 1 && !pairs.expand((p) => p).contains(g.first))
          .map((g) => g.first)
          .toList();
      if (singletons.isNotEmpty) {
        pairs.add([singletons.first, jokers.first.copyWith(isJoker: true)]);
      }
    }

    return PairResult(
      pairs: pairs.take(5).toList(),
      isPairMode: pairs.length >= 5,
    );
  }
}

// lib/engine/risk_calculator.dart
class RiskCalculator {
  /// 0.0 = riski yok (101 açık), 1.0 = çok riskli
  double calculate({
    required int score,
    required int ungroupedCount,
    required int jokerCount,
  }) {
    if (score >= 101) return 0.0;
    
    final baseRisk = 1.0 - (score / 101.0);
    final ungroupedPenalty = ungroupedCount * 0.04;
    final jokerBonus = jokerCount * 0.1;

    return (baseRisk + ungroupedPenalty - jokerBonus).clamp(0.0, 1.0);
  }
}
