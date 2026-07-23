import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner_wrapper.dart';

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
      builder: (context, child) => OfflineBannerWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
