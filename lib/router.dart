import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/ambience/screens/home_screen.dart';
import 'features/ambience/screens/ambience_details_screen.dart';
import 'features/player/screens/session_player_screen.dart';
import 'features/journal/screens/reflection_screen.dart';
import 'features/journal/screens/journal_history_screen.dart';
import 'features/journal/screens/journal_detail_screen.dart';
import 'features/sessions/screens/sessions_library_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/providers/haptic_settings_provider.dart';
import 'shared/theme/colors.dart';

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
              const NoTransitionPage(child: SessionsLibraryScreen()),
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
              ? const Color(0xFF1A1D21).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.92),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  isDark: isDark,
                  onTap: () {
                    HapticSettingsNotifier.triggerHaptic();
                    context.go('/');
                  },
                ),
                _NavItem(
                  icon: Icons.library_music_outlined,
                  activeIcon: Icons.library_music_rounded,
                  label: 'Sessions',
                  isActive: _currentIndex == 1,
                  isDark: isDark,
                  onTap: () {
                    HapticSettingsNotifier.triggerHaptic();
                    context.go('/sessions');
                  },
                ),
                _NavItem(
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Journal',
                  isActive: _currentIndex == 2,
                  isDark: isDark,
                  onTap: () {
                    HapticSettingsNotifier.triggerHaptic();
                    context.go('/journal');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.orange.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive
                    ? AppColors.orange
                    : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
