import 'package:flutter/foundation.dart';
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
      _readValue('API_BASE_URL') ?? _defaultApiBaseUrl;

  static String? get googleServerClientId =>
      _readValue('GOOGLE_SERVER_CLIENT_ID');

  static String get mobileAuthBaseUrl => '$apiBaseUrl/mobile-auth';

  static String get _defaultApiBaseUrl {
    return '2pbpgoin-production.up.railway.app';
    // if (kIsWeb) {
    //   return 'http://127.0.0.1:8000/api';
    // }

    // switch (defaultTargetPlatform) {
    //   case TargetPlatform.android:
    //     return 'http://10.0.2.2:8000/api';
    //   case TargetPlatform.iOS:
    //   case TargetPlatform.macOS:
    //   case TargetPlatform.windows:
    //   case TargetPlatform.linux:
    //     return 'http://127.0.0.1:8000/api';
    //   case TargetPlatform.fuchsia:
    //     return 'http://127.0.0.1:8000/api';
    // }
  }
}
