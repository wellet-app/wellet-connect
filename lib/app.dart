import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/invite_code_screen.dart';
import 'screens/onboarding/health_permissions_screen.dart';
import 'screens/onboarding/notification_permissions_screen.dart';
import 'screens/onboarding/first_sync_screen.dart';

/// Provider that checks if onboarding has been completed.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
});

class WelletConnectApp extends ConsumerWidget {
  const WelletConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated =
            authState.status == AuthStatus.authenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        final isOnboarding =
            state.matchedLocation.startsWith('/onboarding');

        // Allow onboarding routes without auth
        if (isOnboarding) return null;

        if (!isAuthenticated && !isLoginRoute) return '/login';

        // Check onboarding completion
        if (isAuthenticated && !isLoginRoute && !isOnboarding) {
          final completed = onboardingComplete.valueOrNull ?? false;
          if (!completed && state.matchedLocation == '/') {
            return '/onboarding/welcome';
          }
        }

        if (isAuthenticated && isLoginRoute) {
          final completed = onboardingComplete.valueOrNull ?? false;
          if (!completed) return '/onboarding/welcome';
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Onboarding routes
        GoRoute(
          path: '/onboarding/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/invite',
          builder: (context, state) => const InviteCodeScreen(),
        ),
        GoRoute(
          path: '/onboarding/health',
          builder: (context, state) => const HealthPermissionsScreen(),
        ),
        GoRoute(
          path: '/onboarding/notifications',
          builder: (context, state) =>
              const NotificationPermissionsScreen(),
        ),
        GoRoute(
          path: '/onboarding/sync',
          builder: (context, state) => const FirstSyncScreen(),
        ),

        // Settings (outside of shell route so it has its own nav)
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Main app shell with bottom nav
        ShellRoute(
          builder: (context, state, child) {
            return _ScaffoldWithNav(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/medications',
              builder: (context, state) => const MedicationsScreen(),
            ),
            GoRoute(
              path: '/checkin',
              builder: (context, state) => const CheckinScreen(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Wellet Connect',
      theme: WelletTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNav({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WelletTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Semantics(
          label: 'Main navigation',
          child: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined),
                activeIcon: Icon(Icons.medication),
                label: 'Medications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_emotions_outlined),
                activeIcon: Icon(Icons.emoji_emotions),
                label: 'Check-in',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/medications')) return 1;
    if (location.startsWith('/checkin')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/medications');
        break;
      case 2:
        context.go('/checkin');
        break;
    }
  }
}
