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
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/order/data/datasources/order_remote_datasource.dart';
import '../../features/order/data/repositories/order_repository.dart';
import '../../features/order/presentation/bloc/address_bloc.dart';
import '../../features/order/presentation/bloc/checkout_bloc.dart';
import '../../features/order/presentation/bloc/order_bloc.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository.dart';
import '../../features/review/data/datasources/review_remote_datasource.dart';
import '../../features/review/data/repositories/review_repository.dart';
import '../../features/review/presentation/bloc/review_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/return_request/data/datasources/return_remote_datasource.dart';
import '../../features/return_request/data/repositories/return_repository.dart';
import '../../features/return_request/presentation/bloc/return_bloc.dart';

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
    ..registerLazySingleton(() => CartRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => CartRepository(getIt<CartRemoteDataSource>()))
    ..registerLazySingleton(() => CartBloc(getIt<CartRepository>()))
    ..registerLazySingleton(() => AddressRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => ShippingRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => OrderRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => AddressRepository(getIt<AddressRemoteDataSource>()))
    ..registerLazySingleton(() => ShippingRepository(getIt<ShippingRemoteDataSource>()))
    ..registerLazySingleton(() => OrderRepository(getIt<OrderRemoteDataSource>()))
    ..registerLazySingleton(() => PaymentRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => PaymentRepository(getIt<PaymentRemoteDataSource>()))
    ..registerLazySingleton(() => ReviewRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => ReviewRepository(getIt<ReviewRemoteDataSource>()))
    ..registerLazySingleton(() => NotificationRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => NotificationRepository(getIt<NotificationRemoteDataSource>()))
    ..registerLazySingleton(() => ReturnRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton(() => ReturnRepository(getIt<ReturnRemoteDataSource>()))
    ..registerFactory(() => AuthCubit(getIt<AuthRepository>()))
    ..registerFactory(() => ProductListBloc(getIt<CatalogRepository>()))
    ..registerFactory(() => ProductDetailBloc(getIt<CatalogRepository>()))
    ..registerFactory(() => SearchBloc(getIt<CatalogRepository>(), getIt<SharedPreferences>()))
    ..registerFactory(() => AddressBloc(getIt<AddressRepository>()))
    ..registerFactory(() => CheckoutBloc(
          getIt<OrderRepository>(),
          getIt<AddressRepository>(),
          getIt<ShippingRepository>(),
          getIt<CartRepository>(),
        ))
    ..registerFactory(() => OrderBloc(getIt<OrderRepository>()))
    ..registerFactory(() => ReviewBloc(getIt<ReviewRepository>()))
    ..registerLazySingleton(() => NotificationBloc(getIt<NotificationRepository>()))
    ..registerFactory(() => ReturnBloc(getIt<ReturnRepository>()));
}
