import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../features/catalog/data/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/bloc/product_detail_bloc.dart';
import '../../features/catalog/presentation/bloc/product_list_bloc.dart';
import '../../features/catalog/presentation/bloc/search_bloc.dart';

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
    ..registerLazySingleton(() => CatalogRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => CatalogRepository(getIt<CatalogRemoteDataSource>()))
    ..registerFactory(() => AuthCubit(getIt<AuthRepository>()))
    ..registerFactory(() => ProductListBloc(getIt<CatalogRepository>()))
    ..registerFactory(() => ProductDetailBloc(getIt<CatalogRepository>()))
    ..registerFactory(() => SearchBloc(getIt<CatalogRepository>(), getIt<SharedPreferences>()));
}
