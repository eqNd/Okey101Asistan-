// lib/ui/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class GamePlayer {
  final String name;
  String get abbreviation => name.length > 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase();
  const GamePlayer(this.name);
}

class GameState {
  final List<GamePlayer> players;
  final List<List<int>> rounds;
  final int maxRounds;

  List<int> get totals => List.generate(
    players.length,
    (i) => rounds.fold(0, (sum, r) => sum + (i < r.length ? r[i] : 0)),
  );

  int get leaderIndex {
    final t = totals;
    final min = t.reduce((a, b) => a < b ? a : b);
    return t.indexOf(min);
  }

  const GameState({
    required this.players,
    this.rounds = const [],
    this.maxRounds = 10,
  });

  GameState copyWith({List<GamePlayer>? players, List<List<int>>? rounds, int? maxRounds}) =>
    GameState(
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      maxRounds: maxRounds ?? this.maxRounds,
    );
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState(
    players: const [GamePlayer('Ali'), GamePlayer('Mehmet'), GamePlayer('Ayşe'), GamePlayer('Fatih')],
    rounds: const [
      [12, 0, 45, 33],
      [0, 28, 15, 62],
      [55, 12, 0, 38],
    ],
  ));

  void addRound(List<int> scores) {
    state = state.copyWith(rounds: [...state.rounds, scores]);
  }

  void addPenalty(int roundIdx, int playerIdx, int amount) {
    final newRounds = state.rounds.map((r) => List<int>.from(r)).toList();
    if (roundIdx < newRounds.length) {
      newRounds[roundIdx][playerIdx] += amount;
      state = state.copyWith(rounds: newRounds);
    }
  }

  void startNewGame(List<String> playerNames, int maxRounds) {
    state = GameState(
      players: playerNames.map((n) => GamePlayer(n)).toList(),
      maxRounds: maxRounds,
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier());

// ─── GAME SCREEN ───
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _rebuildControllers(4);
  }

  void _rebuildControllers(int count) {
    for (final c in _controllers) c.dispose();
    _controllers.clear();
    _controllers.addAll(List.generate(count, (_) => TextEditingController()));
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  static const List<Color> playerColors = [
    Color(0xFFD63031), Color(0xFF0984E3), Color(0xFFF9CA24), Color(0xFF00B894),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, game),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGameInfo(game),
                    const SizedBox(height: 10),
                    _buildScoreTable(game),
                    const SizedBox(height: 10),
                    _buildRoundInput(game),
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

  Widget _buildTopBar(BuildContext context, GameState game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('PUAN', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
            fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const Text(' TAKİP', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
            fontWeight: FontWeight.w900, color: AppTheme.accent)),
          Row(children: [
            _iconBtn('＋', () => _showNewGameDialog(context)),
            const SizedBox(width: 8),
            _iconBtn('📋', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _iconBtn(String icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
    ),
  );

  Widget _buildGameInfo(GameState game) {
    final leader = game.players[game.leaderIndex].abbreviation;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _infoCard('EL', '${game.rounds.length}', AppTheme.textPrimary),
          const SizedBox(width: 8),
          _infoCard('LİDER', leader, AppTheme.green),
          const SizedBox(width: 8),
          _infoCard('MOD', '${game.players.length} KİŞİ', AppTheme.accent2),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'SpaceMono',
            fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontFamily: 'Orbitron',
            fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    ),
  );

  Widget _buildScoreTable(GameState game) {
    final totals = game.totals;
    final leader = game.leaderIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface2, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.surface3,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 28, child: Center(child: Text('#',
                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10,
                      color: AppTheme.textSecondary)))),
                  ...game.players.asMap().entries.map((e) => Expanded(
                    child: Text(e.value.abbreviation, textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: e.key == leader ? AppTheme.green : AppTheme.textPrimary)),
                  )),
                ],
              ),
            ),
            // Rows
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: game.rounds.length,
                itemBuilder: (_, ri) {
                  final round = game.rounds[ri];
                  final minVal = round.reduce((a, b) => a < b ? a : b);
                  return Container(
                    decoration: BoxDecoration(
                      color: ri.isEven ? Colors.transparent : Colors.white.withOpacity(0.02),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 28, child: Center(
                          child: Text('${ri + 1}', style: const TextStyle(
                            fontFamily: 'SpaceMono', fontSize: 10, color: AppTheme.textSecondary)))),
                        ...round.asMap().entries.map((e) {
                          final isBest = e.value == minVal;
                          final isPenalty = e.value > 80;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Text('${e.value}', textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rajdhani', fontSize: 13, fontWeight: FontWeight.w600,
                                  color: isPenalty ? AppTheme.accent
                                    : isBest ? AppTheme.green : AppTheme.textPrimary,
                                )),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Totals
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.surface3,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 28, child: Center(
                    child: Text('Σ', style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 10, color: AppTheme.textSecondary)))),
                  ...totals.asMap().entries.map((e) => Expanded(
                    child: Text('${e.value}', textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.w700,
                        color: e.key == leader ? AppTheme.green : AppTheme.textPrimary,
                      )),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundInput(GameState game) {
    if (_controllers.length != game.players.length) {
      _rebuildControllers(game.players.length);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface2, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EL ${game.rounds.length + 1} — PUAN GİR',
              style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 12,
                color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            ...game.players.asMap().entries.map((e) {
              final i = e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: playerColors[i % playerColors.length].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: playerColors[i % playerColors.length].withOpacity(0.4)),
                      ),
                      child: Center(child: Text(e.value.abbreviation,
                        style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: playerColors[i % playerColors.length]))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14,
                          color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary),
                          filled: true, fillColor: AppTheme.surface3,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppTheme.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final cur = int.tryParse(_controllers[i].text) ?? 0;
                        _controllers[i].text = '${cur + 101}';
                        _showPenaltyToast(e.value.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: const Text('+101\nCEZA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'SpaceMono', fontSize: 8,
                            color: AppTheme.accent, height: 1.4)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRound,
                child: const Text('ELİ KAYDET ✓'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRound() {
    final game = ref.read(gameProvider);
    final scores = List.generate(
      game.players.length,
      (i) => int.tryParse(_controllers[i].text) ?? 0,
    );
    ref.read(gameProvider.notifier).addRound(scores);
    for (final c in _controllers) c.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El kaydedildi ✓', style: TextStyle(fontFamily: 'SpaceMono')),
        backgroundColor: AppTheme.surface2, duration: Duration(seconds: 1),
      ),
    );
  }

  void _showPenaltyToast(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name +101 ceza!', style: const TextStyle(
          fontFamily: 'SpaceMono', color: AppTheme.accent)),
        backgroundColor: AppTheme.surface2,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showNewGameDialog(BuildContext context) {
    final controllers = List.generate(4, (i) => TextEditingController(
      text: ['Ali', 'Mehmet', 'Ayşe', 'Fatih'][i]));
    int playerCount = 4;
    int maxRounds = 10;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: const Text('YENİ OYUN', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: playerCount,
                dropdownColor: AppTheme.surface2,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Rajdhani'),
                decoration: const InputDecoration(labelText: 'Oyuncu Sayısı',
                  labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                items: [2,3,4].map((n) => DropdownMenuItem(value: n, child: Text('$n Kişi'))).toList(),
                onChanged: (v) => setDialogState(() => playerCount = v!),
              ),
              const SizedBox(height: 12),
              ...List.generate(playerCount, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: controllers[i],
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Rajdhani'),
                  decoration: InputDecoration(
                    hintText: 'Oyuncu ${i+1}',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )),
              DropdownButtonFormField<int>(
                value: maxRounds,
                dropdownColor: AppTheme.surface2,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Rajdhani'),
                decoration: const InputDecoration(labelText: 'El Sayısı',
                  labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                items: [0,5,10,20].map((n) =>
                  DropdownMenuItem(value: n, child: Text(n==0 ? 'Sınırsız' : '$n El'))).toList(),
                onChanged: (v) => setDialogState(() => maxRounds = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İPTAL', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final names = List.generate(playerCount, (i) =>
                  controllers[i].text.trim().isEmpty ? 'O${i+1}' : controllers[i].text.trim());
                ref.read(gameProvider.notifier).startNewGame(names, maxRounds);
                _rebuildControllers(playerCount);
                Navigator.pop(context);
              },
              child: const Text('BAŞLAT 🚀'),
            ),
          ],
        ),
      ),
    );
  }
}
