import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton(() => TokenStorage(secureStorage))
    ..registerLazySingleton(() => OnboardingStorage(prefs))
    ..registerLazySingleton(() => DioClient(getIt<TokenStorage>()))
    ..registerLazySingleton(() => AuthRemoteDataSource(getIt<DioClient>(), getIt<TokenStorage>()))
    ..registerLazySingleton(() => AuthRepository(getIt<AuthRemoteDataSource>()))
    ..registerFactory(() => AuthCubit(getIt<AuthRepository>()));
}
