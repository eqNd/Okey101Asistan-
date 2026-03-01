// lib/engine/models/analysis_result.dart
import 'tile.dart';

enum GameMode { normal, pairMode }

class TileGroup {
  final List<Tile> tiles;
  final GroupType type;
  final bool usesJoker;
  int get score => tiles.fold(0, (sum, t) => sum + t.value);

  const TileGroup({
    required this.tiles,
    required this.type,
    this.usesJoker = false,
  });
}

enum GroupType { set, run } // Per veya Seri

class Arrangement {
  final List<TileGroup> groups;
  final List<Tile> ungroupedTiles;
  int get score => groups.fold(0, (sum, g) => sum + g.score);
  bool get canOpen => score >= 101;

  const Arrangement({
    required this.groups,
    required this.ungroupedTiles,
  });
}

class AnalysisResult {
  final List<Arrangement> arrangements; // Maksimum 3 alternatif
  final Tile? weakestTile;             // Atılması önerilen taş
  final int totalScore;                // En iyi dizilim puanı
  final bool canOpen;                  // 101 açılışı mümkün mü?
  final double riskScore;             // 0.0 - 1.0
  final int pairCount;                // Çift sayısı
  final GameMode mode;                // Normal / Çifte modu
  final int jokerCount;               // Joker sayısı
  final List<Tile> hand;              // Orijinal el

  int get remainingFor101 => canOpen ? 0 : 101 - totalScore;
  Arrangement get bestArrangement => arrangements.first;

  const AnalysisResult({
    required this.arrangements,
    required this.hand,
    this.weakestTile,
    required this.totalScore,
    required this.canOpen,
    required this.riskScore,
    required this.pairCount,
    required this.mode,
    required this.jokerCount,
  });
}
