import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service managing Firebase Authentication for Disha Saathi.
/// Project: disha-saathi (Disha saathi)
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Gets current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state changes stream for persistent session listening
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Google Sign-In Authentication ---

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled Google Sign-In
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'Google sign-in was cancelled or failed. Please try again.';
    }
  }

  // --- Sign Out ---

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return 'Too many requests. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Internet connection unavailable. Please check your network.';
      default:
        return e.message ?? 'Authentication error. Please try again.';
    }
  }
}
