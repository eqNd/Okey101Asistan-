// lib/ui/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/analysis_provider.dart';
import '../widgets/tile_widget.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _roiController;
  late Animation<double> _roiAnim;

  @override
  void initState() {
    super.initState();
    _roiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _roiAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_roiController);
  }

  @override
  void dispose() {
    _roiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Camera Viewport
                    _buildCameraViewport(),
                    const SizedBox(height: 12),

                    // Quick Stats
                    _buildQuickStats(analysisState),
                    const SizedBox(height: 10),

                    // Progress Bar
                    _buildProgressBar(analysisState),
                    const SizedBox(height: 10),

                    // Detected Tiles
                    if (analysisState.detectedTiles.isNotEmpty)
                      _buildDetectedTiles(analysisState),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Analyze FAB
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'OKEY',
                  style: TextStyle(
                    fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text: '101',
                  style: TextStyle(
                    fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.w900,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _iconButton('⚡', () {}),
              const SizedBox(width: 8),
              _iconButton('⚙', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _buildCameraViewport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E17),
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: [
                // Camera preview (gerçek uygulamada: CameraPreview widget)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A1020), Color(0xFF0D1525)],
                    ),
                  ),
                ),

                // Grid overlay
                CustomPaint(
                  painter: _GridPainter(),
                  child: Container(),
                ),

                // ROI Frame
                AnimatedBuilder(
                  animation: _roiAnim,
                  builder: (_, __) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accent2.withOpacity(_roiAnim.value),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          _roiCorner(Alignment.topLeft),
                          _roiCorner(Alignment.topRight),
                          _roiCorner(Alignment.bottomLeft),
                          _roiCorner(Alignment.bottomRight),
                        ],
                      ),
                    ),
                  ),
                ),

                // Label
                Positioned(
                  bottom: 12, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accent2.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'TAŞLARI ÇERÇEVEYE AL',
                            style: TextStyle(
                              fontFamily: 'SpaceMono', fontSize: 11,
                              color: AppTheme.accent2, letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roiCorner(Alignment align) {
    final isTop = align == Alignment.topLeft || align == Alignment.topRight;
    final isLeft = align == Alignment.topLeft || align == Alignment.bottomLeft;
    return Align(
      alignment: align,
      child: Container(
        width: 16, height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppTheme.accent2, width: 2) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: AppTheme.accent2, width: 2) : BorderSide.none,
            left: isLeft ? const BorderSide(color: AppTheme.accent2, width: 2) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: AppTheme.accent2, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(AnalysisState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard('${state.score}', 'PUAN', AppTheme.green),
          const SizedBox(width: 8),
          _statCard('${state.remainingFor101}', 'EKSİK', AppTheme.accent3),
          const SizedBox(width: 8),
          _statCard('${state.groupCount}', 'GRUP', AppTheme.accent),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontFamily: 'Orbitron', fontSize: 22,
                fontWeight: FontWeight.w700, color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(
              fontFamily: 'SpaceMono', fontSize: 10,
              color: AppTheme.textSecondary,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AnalysisState state) {
    final pct = (state.score / 101.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('101\'E İLERLEME',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppTheme.textSecondary)),
              Text('${(pct * 100).round()}%',
                style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.surface3,
              valueColor: AlwaysStoppedAnimation(
                pct >= 1.0 ? AppTheme.green : AppTheme.accent2,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedTiles(AnalysisState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ALGILANAN TAŞLAR',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11,
                  color: AppTheme.textSecondary, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accent2.withOpacity(0.3)),
                ),
                child: Text('${state.detectedTiles.length} TAŞ',
                  style: const TextStyle(fontFamily: 'SpaceMono',
                    fontSize: 10, color: AppTheme.accent2)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TileRow(tiles: state.detectedTiles, states: state.tileStates),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => ref.read(analysisProvider.notifier).analyze(),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.accent, Color(0xFFFF6B85)],
          ),
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: const Center(child: Text('🔍', style: TextStyle(fontSize: 24))),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent2.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
