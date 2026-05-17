import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String? _readValue(String key) {
    final envValue = dotenv.env[key]?.trim();
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    const dartDefineApiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const dartDefineGoogleServerClientId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    );

    switch (key) {
      case 'API_BASE_URL':
        return dartDefineApiBaseUrl.isNotEmpty ? dartDefineApiBaseUrl : null;
      case 'GOOGLE_SERVER_CLIENT_ID':
        return dartDefineGoogleServerClientId.isNotEmpty
            ? dartDefineGoogleServerClientId
            : null;
      default:
        return null;
    }
  }

  static String get apiBaseUrl =>
      _readValue('API_BASE_URL') ?? 'http://127.0.0.1:8000/api';

  static String? get googleServerClientId =>
      _readValue('GOOGLE_SERVER_CLIENT_ID');
}
