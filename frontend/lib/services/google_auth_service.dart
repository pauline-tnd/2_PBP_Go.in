import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/app_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.isSuccess,
    this.message,
    this.wasCancelled = false,
    this.user,
    this.firebaseToken,
  });

  final bool isSuccess;
  final String? message;
  final bool wasCancelled;
  final User? user;
  final String? firebaseToken;
}

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleServerClientId,
    scopes: ['email', 'profile'],
  );

  static Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return const GoogleAuthResult(
          isSuccess: false,
          wasCancelled: true,
          message: 'Google sign-in cancelled.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential firebaseCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final firebaseUser = firebaseCredential.user;

      if (firebaseUser == null) {
        return const GoogleAuthResult(
          isSuccess: false,
          message: 'Firebase user tidak ditemukan.',
        );
      }

      final googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        return const GoogleAuthResult(
          isSuccess: false,
          message: 'Google token tidak ditemukan.',
        );
      }

      return GoogleAuthResult(
        isSuccess: true,
        user: firebaseUser,
        firebaseToken: googleIdToken,
      );
    } on FirebaseAuthException catch (e) {
      return GoogleAuthResult(
        isSuccess: false,
        message: _firebaseErrorMessage(e.code),
      );
    } catch (e) {
      return GoogleAuthResult(isSuccess: false, message: e.toString());
    }
  }

  static Future<void> signOut() async {
    await Future.wait([
      FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  static String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Email already exist.';

      case 'invalid-credential':
        return 'Invalid credential.';

      case 'network-request-failed':
        return 'Check internet connection.';

      default:
        return 'Login failed ($code)';
    }
  }
}
