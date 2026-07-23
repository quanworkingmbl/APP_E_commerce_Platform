class AppConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'http://localhost:8080',
  );

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const onboardingKey = 'onboarding_completed';
  static const recentSearchKey = 'recent_searches';
}
