import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._remote);

  final AuthRemoteDataSource _remote;

  Future<AuthResponseModel> login(String email, String password) =>
      _remote.login(email: email, password: password);

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

  Future<void> logout() => _remote.logout();

  Future<UserModel> getMe() => _remote.getMe();
}
