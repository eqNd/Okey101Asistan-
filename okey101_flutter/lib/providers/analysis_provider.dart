// lib/providers/analysis_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/models/tile.dart';
import '../engine/models/analysis_result.dart';
import '../engine/analyzer.dart';
import '../ui/widgets/tile_widget.dart';

class AnalysisState {
  final List<Tile> detectedTiles;
  final AnalysisResult? result;
  final bool isAnalyzing;
  final Map<int, TileState> tileStates;

  int get score => result?.totalScore ?? 0;
  int get remainingFor101 => result?.remainingFor101 ?? 101;
  int get groupCount => result?.bestArrangement.groups.length ?? 0;

  const AnalysisState({
    this.detectedTiles = const [],
    this.result,
    this.isAnalyzing = false,
    this.tileStates = const {},
  });

  AnalysisState copyWith({
    List<Tile>? detectedTiles,
    AnalysisResult? result,
    bool? isAnalyzing,
    Map<int, TileState>? tileStates,
  }) => AnalysisState(
    detectedTiles: detectedTiles ?? this.detectedTiles,
    result: result ?? this.result,
    isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    tileStates: tileStates ?? this.tileStates,
  );
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier() : super(const AnalysisState()) {
    _loadDemoHand();
  }

  void _loadDemoHand() {
    final demo = [
      Tile(color: TileColor.red, number: 3),
      Tile(color: TileColor.red, number: 4),
      Tile(color: TileColor.red, number: 5),
      Tile(color: TileColor.blue, number: 7),
      Tile(color: TileColor.blue, number: 7),
      Tile(color: TileColor.yellow, number: 7),
      Tile(color: TileColor.black, number: 11),
      Tile(color: TileColor.black, number: 12),
      Tile(color: TileColor.black, number: 13),
      Tile(color: TileColor.yellow, number: 0),
      Tile(color: TileColor.red, number: 9),
      Tile(color: TileColor.blue, number: 2),
      Tile(color: TileColor.yellow, number: 2),
      Tile(color: TileColor.black, number: 2),
    ];
    state = state.copyWith(detectedTiles: demo);
  }

  Future<void> analyze() async {
    if (state.detectedTiles.isEmpty) return;
    state = state.copyWith(isAnalyzing: true);

    final analyzer = OkeyAnalyzer(
      okeyTile: Tile(color: TileColor.yellow, number: 5),
    );
    final result = await analyzer.analyze(state.detectedTiles);

    // Tile durumlarını hesapla
    final states = <int, TileState>{};
    final grouped = result.bestArrangement.groups.expand((g) => g.tiles).toSet();
    for (int i = 0; i < state.detectedTiles.length; i++) {
      final t = state.detectedTiles[i];
      if (grouped.contains(t)) {
        states[i] = TileState.highlighted;
      } else if (result.weakestTile == t) {
        states[i] = TileState.weak;
      }
    }

    state = state.copyWith(
      result: result,
      isAnalyzing: false,
      tileStates: states,
    );
  }

  void setHand(List<Tile> tiles) {
    state = state.copyWith(detectedTiles: tiles, result: null, tileStates: {});
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(),
);
