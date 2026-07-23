import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_placeholder_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter(this._tokenStorage, this._onboardingStorage);

  final TokenStorage _tokenStorage;
  final OnboardingStorage _onboardingStorage;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/register'];
      if (publicRoutes.contains(path)) return null;

      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(
          onFinished: () async {
            final onboardingDone = _onboardingStorage.isCompleted;
            final token = await _tokenStorage.getAccessToken();
            if (!context.mounted) return;
            if (token != null && token.isNotEmpty) {
              context.go('/home');
            } else if (!onboardingDone) {
              context.go('/onboarding');
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          onComplete: () async {
            await _onboardingStorage.setCompleted();
            if (context.mounted) context.go('/login');
          },
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePlaceholderPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthCubit>()..checkSession(),
          child: const ProfilePage(),
        ),
      ),
    ],
  );
}
