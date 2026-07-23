import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient, this._tokenStorage);

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  Dio get _dio => _dioClient.dio;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final auth = _parseAuthResponse(response.data);
    await persistTokens(auth);
    return auth;
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phone != null) 'phone': phone,
      },
    );
    final auth = _parseAuthResponse(response.data);
    await persistTokens(auth);
    return auth;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    }
    await _tokenStorage.clearTokens();
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    final data = response.data?['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  AuthResponseModel _parseAuthResponse(Map<String, dynamic>? body) {
    final data = body?['data'] as Map<String, dynamic>;
    final auth = AuthResponseModel.fromJson(data);
    return auth;
  }

  Future<void> persistTokens(AuthResponseModel auth) async {
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
  }
}
