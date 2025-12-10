class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Auth0 Configuration
  static const String auth0Domain = String.fromEnvironment('AUTH0_DOMAIN');
  static const String auth0ClientId = String.fromEnvironment('AUTH0_CLIENT_ID');

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'My Daily Log',
  );
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  // Environment helpers
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  // Validation
  static bool get isValid {
    return auth0Domain.isNotEmpty &&
        auth0ClientId.isNotEmpty &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }

  // Debug info
  static Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'auth0Domain': auth0Domain,
    'auth0ClientId': auth0ClientId.isNotEmpty
        ? '***${auth0ClientId.substring(auth0ClientId.length - 4)}'
        : 'NOT_SET',
    'supabaseUrl': supabaseUrl,
    'apiBaseUrl': apiBaseUrl,
    'appName': appName,
    'enableLogging': enableLogging,
  };
}
