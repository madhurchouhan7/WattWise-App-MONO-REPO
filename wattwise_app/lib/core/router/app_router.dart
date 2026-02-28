import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';
import 'package:wattwise_app/feature/on_boarding/screens/on_boarding_screen.dart';
import 'package:wattwise_app/feature/root/screens/root_screen.dart';
import 'package:wattwise_app/feature/splash_screen/splash_screen.dart';
import 'package:wattwise_app/feature/welcome/screens/welcome_screen.dart';

// Debugging: state provider to override onboarding status for the current session
final sessionOnboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Central routing widget.
/// Listens to [authStateProvider] and decides which screen to render.
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // While Firebase is initialising — show the splash.
      loading: () => const SplashScreen(),

      // Auth error (rare — e.g. network down at launch)
      error: (_, __) => const WelcomeScreen(),

      data: (user) {
        if (user == null) {
          // Not signed in → show Welcome → Auth flow
          return const WelcomeScreen();
        }

        final isLocalOnboardingComplete = ref.watch(
          sessionOnboardingCompleteProvider,
        );

        // For debugging: Force onboarding flow unless we just completed it in this session.
        if (!isLocalOnboardingComplete) {
          return const OnBoardingScreen();
        }

        // Fully authenticated & onboarded → main app
        return const RootScreen();
      },
    );
  }
}
