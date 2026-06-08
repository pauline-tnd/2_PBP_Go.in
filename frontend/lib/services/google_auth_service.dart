import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'app_config.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.isSuccess,
    this.message,
    this.wasCancelled = false,
  });

  final bool isSuccess;
  final String? message;
  final bool wasCancelled;
}

class GoogleAuthService {
  static GoogleSignIn _buildGoogleSignIn() {
    final serverClientId = AppConfig.googleServerClientId;

    return GoogleSignIn(
      clientId: serverClientId != null && serverClientId.isNotEmpty
          ? serverClientId
          : null,
      scopes: const ['email', 'profile'],
      serverClientId: serverClientId != null && serverClientId.isNotEmpty
          ? serverClientId
          : null,
    );
  }

  static Future<GoogleAuthResult> signInWithGoogle(String apiBaseUrl) async {
    try {
      final googleSignIn = _buildGoogleSignIn();
      await googleSignIn.signOut();

      final account = await googleSignIn.signIn();
      if (account == null) {
        return const GoogleAuthResult(
          isSuccess: false,
          wasCancelled: true,
          message: 'Google sign-in was cancelled.',
        );
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;

      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        return const GoogleAuthResult(
          isSuccess: false,
          message:
              'Google sign-in did not return a usable token. Check the Google client configuration.',
        );
      }

      final body = <String, String>{};
      if (idToken != null && idToken.isNotEmpty) {
        body['id_token'] = idToken;
      } else if (accessToken != null && accessToken.isNotEmpty) {
        body['access_token'] = accessToken;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/google-login'),
        headers: {'Accept': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic>? data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : null;

      if (response.statusCode == 200) {
        return const GoogleAuthResult(isSuccess: true);
      }

      return GoogleAuthResult(
        isSuccess: false,
        message:
            data?['message']?.toString() ??
            'Google sign-in failed. Please try again.',
      );
    } catch (error) {
      return GoogleAuthResult(
        isSuccess: false,
        message:
            'Unable to complete Google sign-in. Check your network and Google client configuration. $error',
      );
    }
  }
}
