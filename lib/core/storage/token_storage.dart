import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  TokenStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _secureStorage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() => _secureStorage.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }
}

class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  bool get isCompleted => _prefs.getBool(AppConstants.onboardingKey) ?? false;

  Future<void> setCompleted() => _prefs.setBool(AppConstants.onboardingKey, true);
}
