import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final response = await _repository.login(email, password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: response.user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Đăng nhập thất bại'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final response = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: response.user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Đăng ký thất bại'));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.initial());
  }

  Future<void> checkSession() async {
    try {
      final user = await _repository.getMe();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(const AuthState.initial());
    }
  }
}
