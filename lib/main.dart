import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final appRouter = AppRouter(getIt<TokenStorage>(), getIt<OnboardingStorage>());

  runApp(ECommerceApp(router: appRouter.router));
}

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-Commerce',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
