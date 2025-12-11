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
  // WARNING: Do not log or expose this information in production environments.
  // Sensitive values are masked or omitted for safety.
  static Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'auth0Domain': auth0Domain.isNotEmpty
        ? '${auth0Domain.substring(0, 3)}***${auth0Domain.substring(auth0Domain.length - 4)}'
        : 'NOT_SET',
    'auth0ClientId': auth0ClientId.isNotEmpty
        ? '***${auth0ClientId.substring(auth0ClientId.length - 4)}'
        : 'NOT_SET',
    'supabaseUrl': supabaseUrl.isNotEmpty
        ? '${supabaseUrl.substring(0, 5)}***${supabaseUrl.substring(supabaseUrl.length - 4)}'
        : 'NOT_SET',
    'apiBaseUrl': apiBaseUrl.isNotEmpty
        ? '${apiBaseUrl.substring(0, 5)}***${apiBaseUrl.substring(apiBaseUrl.length - 4)}'
        : 'NOT_SET',
    'appName': appName,
    'enableLogging': enableLogging,
  };
}
