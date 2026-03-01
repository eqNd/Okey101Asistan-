// lib/engine/analyzer.dart
//
// Deterministik, kural bazlı Okey 101 analiz motoru.
// Yapay zeka veya harici API kullanılmaz.
//

import 'dart:isolate';
import 'models/tile.dart';
import 'models/analysis_result.dart';
import 'set_finder.dart';
import 'run_finder.dart';
import 'joker_resolver.dart';
import 'pair_evaluator.dart';
import 'risk_calculator.dart';

class OkeyAnalyzer {
  final Tile okeyTile; // Mevcut turda belirlenen Okey taşı

  OkeyAnalyzer({required this.okeyTile});

  /// Ana analiz metodu. Dart Isolate'te çalıştırılabilir.
  Future<AnalysisResult> analyze(List<Tile> hand) async {
    // Isolate'te çalıştır (UI thread'i bloklamaz)
    return await Isolate.run(() => _analyzeSync(hand));
  }

  /// Senkron analiz (test için veya isolate içinde)
  AnalysisResult analyzeSync(List<Tile> hand) => _analyzeSync(hand);

  AnalysisResult _analyzeSync(List<Tile> rawHand) {
    // 1. Joker'ları işaretle
    final hand = rawHand.map((t) {
      final isJoker = (t.number == 0) ||
          (t.color == okeyTile.color && t.number == okeyTile.number && !t.isFakeOkey);
      return t.copyWith(isJoker: isJoker);
    }).toList();

    final jokers = hand.where((t) => t.isJoker).toList();
    final regulars = hand.where((t) => !t.isJoker).toList();
    final jokerCount = jokers.length;

    // 2. Çifte modunu kontrol et
    final pairEval = PairEvaluator();
    final pairResult = pairEval.evaluate(regulars, jokers);
    if (pairResult.isPairMode) {
      return _buildPairResult(hand, pairResult, jokerCount);
    }

    // 3. Tüm geçerli per ve serileri bul
    final setFinder = SetFinder();
    final runFinder = RunFinder();

    final allSets = setFinder.findAll(regulars, jokers);
    final allRuns = runFinder.findAll(regulars, jokers);

    // 4. Joker optimizasyonu
    final jokerResolver = JokerResolver();
    final enhancedGroups = jokerResolver.resolve(
      [...allSets, ...allRuns], jokers,
    );

    // 5. Backtracking ile en iyi 3 dizilimi bul
    final arrangements = _findBestArrangements(hand, enhancedGroups, maxResults: 3);

    // 6. En iyi skoru hesapla
    final bestScore = arrangements.isNotEmpty ? arrangements.first.score : 0;
    final canOpen = bestScore >= 101;

    // 7. En zayıf taşı belirle
    final usedInBest = arrangements.isNotEmpty
        ? arrangements.first.groups.expand((g) => g.tiles).toSet()
        : <Tile>{};
    final ungrouped = regulars.where((t) => !usedInBest.contains(t)).toList();
    final weakest = _findWeakestTile(ungrouped, regulars);

    // 8. Risk skoru
    final risk = RiskCalculator().calculate(
      score: bestScore,
      ungroupedCount: ungrouped.length,
      jokerCount: jokerCount,
    );

    return AnalysisResult(
      arrangements: arrangements.isNotEmpty
          ? arrangements
          : [Arrangement(groups: [], ungroupedTiles: hand)],
      hand: hand,
      weakestTile: weakest,
      totalScore: bestScore,
      canOpen: canOpen,
      riskScore: risk,
      pairCount: pairResult.pairCount,
      mode: GameMode.normal,
      jokerCount: jokerCount,
    );
  }

  /// Backtracking ile en iyi N dizilimi bulur.
  /// Pruning: 101'e erişilemeyen dallar kırpılır.
  List<Arrangement> _findBestArrangements(
    List<Tile> hand,
    List<TileGroup> candidates,
    {int maxResults = 3}
  ) {
    final results = <Arrangement>[];
    final usedTiles = <int>{}; // Tile index seti

    void backtrack(int start, List<TileGroup> current, int currentScore) {
      // Pruning: kalan taşlarla bile 101'e ulaşamayacaksak dur
      final maxPossible = currentScore +
          hand.where((t) => !usedTiles.contains(hand.indexOf(t))).fold(0, (s, t) => s + t.value);
      if (maxPossible < 101 && results.any((r) => r.canOpen)) return;

      // Geçerli durumu kaydet
      final unused = hand.where((t) => !usedTiles.contains(hand.indexOf(t))).toList();
      final arr = Arrangement(groups: List.from(current), ungroupedTiles: unused);
      
      if (results.length < maxResults) {
        results.add(arr);
        results.sort((a, b) => b.score.compareTo(a.score));
      } else if (arr.score > results.last.score) {
        results.last = arr;
        results.sort((a, b) => b.score.compareTo(a.score));
      }

      if (results.length >= maxResults && results.first.canOpen) return;

      for (int i = start; i < candidates.length; i++) {
        final group = candidates[i];
        final groupIndices = group.tiles.map((t) => hand.indexOf(t)).toList();
        
        // Örtüşme kontrolü
        if (groupIndices.any((idx) => usedTiles.contains(idx) || idx == -1)) continue;

        groupIndices.forEach(usedTiles.add);
        backtrack(i + 1, [...current, group], currentScore + group.score);
        groupIndices.forEach(usedTiles.remove);
      }
    }

    backtrack(0, [], 0);
    return results;
  }

  /// Elde değersiz taşı belirler (weighted score)
  Tile? _findWeakestTile(List<Tile> ungrouped, List<Tile> allRegulars) {
    if (ungrouped.isEmpty) return null;

    // Her taşın "gelecek potansiyeli" skoru
    double score(Tile t) {
      // Birden fazla grupta yer alabiliyorsa daha değerli
      int connections = allRegulars.where((other) =>
        other != t && (
          other.number == t.number || // Per potansiyeli
          (other.color == t.color && (other.number - t.number).abs() <= 2) // Seri potansiyeli
        )
      ).length;
      return t.value + connections * 3.0;
    }

    ungrouped.sort((a, b) => score(a).compareTo(score(b)));
    return ungrouped.first;
  }

  AnalysisResult _buildPairResult(
    List<Tile> hand,
    PairResult pairResult,
    int jokerCount,
  ) {
    final pairGroups = pairResult.pairs.map((pair) => TileGroup(
      tiles: pair,
      type: GroupType.set,
    )).toList();

    final score = pairGroups.fold(0, (s, g) => s + g.score);
    final unused = hand.where((t) => !pairGroups.expand((g) => g.tiles).contains(t)).toList();

    return AnalysisResult(
      arrangements: [Arrangement(groups: pairGroups, ungroupedTiles: unused)],
      hand: hand,
      totalScore: score,
      canOpen: pairResult.isPairMode, // 5 çift = açılış
      riskScore: pairResult.isPairMode ? 0.0 : 0.5,
      pairCount: pairResult.pairCount,
      mode: GameMode.pairMode,
      jokerCount: jokerCount,
    );
  }
}
