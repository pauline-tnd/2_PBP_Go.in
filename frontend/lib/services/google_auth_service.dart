import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.isSuccess,
    this.message,
    this.wasCancelled = false,
    this.user,
    this.idToken,
  });

  final bool isSuccess;
  final String? message;
  final bool wasCancelled;
  final User? user; // Firebase User
  final String? idToken;
}

class GoogleAuthService {
  // v7.x: instance langsung, tidak perlu build method
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      // Sign out dulu biar muncul account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return const GoogleAuthResult(
          isSuccess: false,
          wasCancelled: true,
          message: 'Google sign-in dibatalkan.',
        );
      }

      // Ambil auth tokens dari Google
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      // Buat credential untuk Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase pakai credential Google
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      return GoogleAuthResult(
        isSuccess: true,
        user: userCredential.user,
        idToken: googleAuth.idToken,
      );
    } on FirebaseAuthException catch (e) {
      return GoogleAuthResult(
        isSuccess: false,
        message: _firebaseErrorMessage(e.code),
      );
    } catch (error) {
      return GoogleAuthResult(
        isSuccess: false,
        message:
            'Login with Google failed. Check your internet connection. $error',
      );
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
        return 'Email already exist. Use another method to login.';
      case 'invalid-credential':
        return 'Invalid credential. Try again.';
      case 'network-request-failed':
        return 'Failed to connect to server. Check your internet connection.';
      default:
        return 'Login failed ($code). Try again.';
    }
  }
}
