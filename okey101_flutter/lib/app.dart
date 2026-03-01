// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/screens/camera_screen.dart';
import 'ui/screens/manual_screen.dart';
import 'ui/screens/result_screen.dart';
import 'ui/screens/game_screen.dart';

class OkeyApp extends StatelessWidget {
  const OkeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okey 101 Asistanı',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    CameraScreen(),
    ManualScreen(),
    ResultScreen(),
    GameScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => ref.read(currentTabProvider.notifier).state = i,
          backgroundColor: AppTheme.surface,
          elevation: 0,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.camera_alt, color: AppTheme.accent2),
              label: 'ANALİZ',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.edit, color: AppTheme.accent2),
              label: 'MANUEL',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.accent2),
              label: 'SONUÇ',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.sports_esports, color: AppTheme.accent2),
              label: 'OYUN',
            ),
          ],
        ),
      ),
    );
  }
}
