// lib/ui/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../engine/models/analysis_result.dart';
import '../../providers/analysis_provider.dart';
import '../widgets/tile_widget.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});
  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _selectedArrangement = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final result = state.result;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: result == null
                  ? _buildEmpty()
                  : _buildResult(result),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: const [
            Text('ANALİZ', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
              fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            Text(' SONUCU', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
              fontWeight: FontWeight.w900, color: AppTheme.accent)),
          ]),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border)),
            child: const Center(child: Text('📤', style: TextStyle(fontSize: 16))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Henüz analiz yapılmadı', style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 13, color: AppTheme.textSecondary)),
          SizedBox(height: 6),
          Text('Analiz sekmesinden taşlarını tara', style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResult(AnalysisResult result) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero card
          _buildHeroCard(result),
          const SizedBox(height: 12),

          // Arrangement tabs
          _buildArrangementTabs(result),
          const SizedBox(height: 8),

          // Arrangement view
          _buildArrangementView(result),
          const SizedBox(height: 10),

          // Insight cards
          _buildInsightCards(result),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeroCard(AnalysisResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: result.canOpen ? AppTheme.green.withOpacity(0.5) : AppTheme.border,
          ),
        ),
        child: Column(
          children: [
            // Top gradient line
            Container(height: 3, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(colors: result.canOpen
                  ? [AppTheme.green, AppTheme.accent2]
                  : [AppTheme.accent, AppTheme.accent3]),
            )),
            const SizedBox(height: 16),

            Text(
              result.canOpen ? '101 AÇILIŞI MÜMKÜN!' : '101\'E ${result.remainingFor101} PUAN EKSİK',
              style: TextStyle(
                fontFamily: 'Orbitron', fontSize: 13, letterSpacing: 2,
                color: result.canOpen ? AppTheme.green : AppTheme.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.totalScore}',
              style: TextStyle(
                fontFamily: 'Orbitron', fontSize: 56, fontWeight: FontWeight.w900,
                color: result.canOpen ? AppTheme.green : AppTheme.textPrimary,
                shadows: result.canOpen ? [
                  Shadow(color: AppTheme.green.withOpacity(0.5), blurRadius: 30)
                ] : null,
              ),
            ),
            Text(
              result.canOpen ? 'Aşağıdaki dizilimle açılabilirsin' : 'En iyi strateji için alternatiflere bak',
              style: const TextStyle(fontFamily: 'Rajdhani', fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrangementTabs(AnalysisResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(result.arrangements.length, (i) {
          final isActive = _selectedArrangement == i;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedArrangement = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accent2.withOpacity(0.15) : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppTheme.accent2 : AppTheme.border,
                  ),
                ),
                child: Text('OPSİYON ${i + 1}',
                  style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10,
                    color: isActive ? AppTheme.accent2 : AppTheme.textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildArrangementView(AnalysisResult result) {
    if (_selectedArrangement >= result.arrangements.length) return const SizedBox();
    final arr = result.arrangements[_selectedArrangement];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface2, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DİZİLİM GÖSTERİMİ', style: TextStyle(
              fontFamily: 'SpaceMono', fontSize: 10, color: AppTheme.textSecondary,
              letterSpacing: 1)),
            const SizedBox(height: 10),

            ...arr.groups.asMap().entries.map((e) {
              final group = e.value;
              final isSet = group.type == GroupType.set;
              final color = isSet ? AppTheme.green : AppTheme.accent2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 4, height: 4, decoration: BoxDecoration(
                        shape: BoxShape.circle, color: color)),
                      const SizedBox(width: 6),
                      Text(
                        '${isSet ? 'PER' : 'SERİ'} ${e.key + 1}  —  ${group.score} puan'
                        '${group.usesJoker ? '  (Joker)' : ''}',
                        style: TextStyle(fontFamily: 'Rajdhani', fontSize: 13,
                          fontWeight: FontWeight.w600, color: color),
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: group.tiles.map((t) => TileWidget(
                        tile: t,
                        state: isSet ? TileState.highlighted : TileState.paired,
                      )).toList(),
                    ),
                  ],
                ),
              );
            }),

            if (arr.ungroupedTiles.isNotEmpty) ...[
              Row(children: const [
                Icon(Icons.close, size: 12, color: AppTheme.accent),
                SizedBox(width: 4),
                Text('GEREKSİZ TAŞLAR', style: TextStyle(fontFamily: 'Rajdhani',
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
              ]),
              const SizedBox(height: 5),
              Wrap(
                spacing: 4, runSpacing: 4,
                children: arr.ungroupedTiles.map((t) => TileWidget(
                  tile: t, state: TileState.weak,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards(AnalysisResult result) {
    final riskPct = (result.riskScore * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: [
          _insightCard('🎯', 'ZOR ÇIKARILACAK',
            result.weakestTile != null ? result.weakestTile!.displayName : '—'),
          _insightCard('⚡', 'RİSK SKORU', '$riskPct%'),
          _insightCard('🃏', 'ÇİFT SAYISI', '${result.pairCount}/5'),
          _insightCard('🔥', 'MOD', result.mode == GameMode.pairMode ? 'ÇİFTE' : 'NORMAL'),
        ],
      ),
    );
  }

  Widget _insightCard(String icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'SpaceMono',
                fontSize: 9, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontFamily: 'Rajdhani',
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
