import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/catalog/presentation/bloc/product_detail_bloc.dart';
import '../../features/catalog/presentation/bloc/product_list_bloc.dart';
import '../../features/catalog/presentation/bloc/search_bloc.dart';
import '../../features/catalog/presentation/pages/home_page.dart';
import '../../features/catalog/presentation/pages/product_detail_page.dart';
import '../../features/catalog/presentation/pages/search_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter(this._tokenStorage, this._onboardingStorage);

  final TokenStorage _tokenStorage;
  final OnboardingStorage _onboardingStorage;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final path = state.matchedLocation;
      const publicRoutes = ['/splash', '/onboarding', '/login', '/register'];
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider.value(
            value: getIt<CartBloc>(),
            child: MainShellPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<ProductListBloc>(),
                  child: const HomePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<ProductListBloc>(),
                  child: const HomePage(title: 'Danh mục'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => BlocProvider.value(
                  value: getIt<AuthCubit>()..checkSession(),
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SearchBloc>(),
          child: const SearchPage(),
        ),
      ),
      GoRoute(
        path: '/product/:slug',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ProductDetailBloc>(),
          child: ProductDetailPage(slug: state.pathParameters['slug']!),
        ),
      ),
    ],
  );
}
