class AppConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const onboardingKey = 'onboarding_completed';
}
