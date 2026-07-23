import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient(TokenStorage tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage, dio: _dio));
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
