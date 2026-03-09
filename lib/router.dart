import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/ambience/screens/home_screen.dart';
import 'features/ambience/screens/ambience_details_screen.dart';
import 'features/player/screens/session_player_screen.dart';
import 'features/journal/screens/reflection_screen.dart';
import 'features/journal/screens/journal_history_screen.dart';
import 'features/journal/screens/journal_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/providers/haptic_settings_provider.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _ScaffoldWithNav(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/sessions',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/journal',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: JournalHistoryScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/ambience/:id',
      builder: (context, state) =>
          AmbienceDetailsScreen(ambienceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const SessionPlayerScreen(),
    ),
    GoRoute(
      path: '/reflection/:ambienceId',
      builder: (context, state) =>
          ReflectionScreen(ambienceId: state.pathParameters['ambienceId']!),
    ),
    GoRoute(
      path: '/journal/:id',
      builder: (context, state) =>
          JournalDetailScreen(entryId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const _ScaffoldWithNav({required this.child, required this.state});

  int get _currentIndex {
    final location = state.uri.path;
    if (location.startsWith('/journal')) return 2;
    if (location.startsWith('/sessions')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.6),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            HapticSettingsNotifier.triggerHaptic();
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/sessions');
                break;
              case 2:
                context.go('/journal');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle),
              label: 'SESSIONS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'JOURNAL',
            ),
          ],
        ),
      ),
    );
  }
}
