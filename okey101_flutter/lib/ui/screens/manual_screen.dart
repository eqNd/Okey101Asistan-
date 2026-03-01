// lib/ui/screens/manual_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../engine/models/tile.dart';
import '../../providers/analysis_provider.dart';
import '../widgets/tile_widget.dart';
import '../../app.dart';

class ManualScreen extends ConsumerStatefulWidget {
  const ManualScreen({super.key});
  @override
  ConsumerState<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends ConsumerState<ManualScreen> {
  TileColor _selectedColor = TileColor.red;
  List<Tile> _hand = [];
  Tile _okeyTile = Tile(color: TileColor.yellow, number: 5);

  static const _okeyOptions = [
    (TileColor.red, 7, 'K-7'),
    (TileColor.blue, 5, 'M-5'),
    (TileColor.yellow, 5, 'S-5'),
    (TileColor.black, 11, 'SY-11'),
  ];

  static const _colorLabels = {
    TileColor.red: ('KIRMIZI', AppTheme.tileRed),
    TileColor.blue: ('MAVİ', AppTheme.tileBlue),
    TileColor.yellow: ('SARI', AppTheme.tileYellow),
    TileColor.black: ('SİYAH', AppTheme.tileBlack),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MANUEL ', style: TextStyle(fontFamily: 'Orbitron',
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  const Text('GİRİŞ', style: TextStyle(fontFamily: 'Orbitron',
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.accent)),
                  GestureDetector(
                    onTap: () => setState(() => _hand.clear()),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border)),
                      child: const Center(child: Text('🗑', style: TextStyle(fontSize: 16))),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Okey Seçimi
                    _buildOkeySelector(),
                    const SizedBox(height: 12),

                    // Renk sekmeleri
                    _buildColorTabs(),
                    const SizedBox(height: 12),

                    // Numara grid
                    _buildNumGrid(),
                    const SizedBox(height: 12),

                    // El gösterimi
                    _buildHandDisplay(),
                    const SizedBox(height: 12),

                    // Butonlar
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hand.length >= 6 ? _analyzeHand : null,
                            child: const Text('🧠 ANALİZ ET'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _hand.clear()),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: AppTheme.surface2,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Center(child: Text('↺',
                              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOkeySelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OKEY TAŞI SEÇ', style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: _okeyOptions.map((opt) {
              final (color, num, label) = opt;
              final isActive = _okeyTile.color == color && _okeyTile.number == num;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _okeyTile = Tile(color: color, number: num)),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.accent3.withOpacity(0.2) : AppTheme.surface3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? AppTheme.accent3 : AppTheme.border,
                      ),
                    ),
                    child: Center(child: Text(label,
                      style: TextStyle(fontSize: 11, fontFamily: 'SpaceMono',
                        color: isActive ? AppTheme.accent3 : AppTheme.textSecondary))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTabs() {
    return Row(
      children: TileColor.values.map((c) {
        final (label, color) = _colorLabels[c]!;
        final isActive = _selectedColor == c;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedColor = c),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.15) : AppTheme.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? color : AppTheme.border,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Center(child: Text(label,
                style: TextStyle(fontSize: 9, fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w700, color: isActive ? color : AppTheme.textSecondary))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumGrid() {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1,
      ),
      itemCount: 14,
      itemBuilder: (_, i) {
        final isJoker = i == 13;
        final (_, color) = _colorLabels[_selectedColor]!;
        return GestureDetector(
          onTap: () => _addTile(isJoker),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isJoker ? AppTheme.accent3.withOpacity(0.1) : AppTheme.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isJoker ? AppTheme.accent3 : AppTheme.border,
              ),
            ),
            child: Center(
              child: Text(
                isJoker ? 'OKEY' : '${i + 1}',
                style: TextStyle(
                  fontFamily: isJoker ? 'Rajdhani' : 'Orbitron',
                  fontSize: isJoker ? 9 : 13,
                  fontWeight: FontWeight.w700,
                  color: isJoker ? AppTheme.accent3 : color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ELİNDEKİ TAŞLAR', style: TextStyle(
                fontFamily: 'SpaceMono', fontSize: 11, color: AppTheme.textSecondary)),
              Text('${_hand.length} / 14', style: const TextStyle(
                fontFamily: 'SpaceMono', fontSize: 10, color: AppTheme.accent2)),
            ],
          ),
          const SizedBox(height: 8),
          if (_hand.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Taş eklemek için numaralara dokun',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10,
                  color: AppTheme.textSecondary)),
            ))
          else
            Wrap(
              spacing: 4, runSpacing: 4,
              children: _hand.asMap().entries.map((e) => GestureDetector(
                onTap: () => setState(() => _hand.removeAt(e.key)),
                child: TileWidget(tile: e.value, state: e.value.isJoker ? TileState.selected : TileState.normal),
              )).toList(),
            ),
        ],
      ),
    );
  }

  void _addTile(bool isJoker) {
    if (_hand.length >= 21) return;
    setState(() {
      _hand.add(Tile(
        color: _selectedColor,
        number: isJoker ? 0 : 0, // placeholder
        isJoker: isJoker,
      ));
    });
  }

  void _analyzeHand() {
    ref.read(analysisProvider.notifier).setHand(_hand);
    ref.read(analysisProvider.notifier).analyze();
    ref.read(currentTabProvider.notifier).state = 2; // Sonuç sekmesine geç
  }
}
