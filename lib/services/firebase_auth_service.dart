import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // --- Phone Number OTP Authentication ---

  static Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_mapFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError('Unable to send Phone OTP. Please check your internet connection.');
    }
  }

  static Future<UserCredential?> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'Invalid OTP code. Please try again.';
    }
  }

  // --- Google Sign-In Authentication (Web Popup/Redirect & Native Mobile) ---

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        try {
          return await _auth.signInWithPopup(googleProvider);
        } on FirebaseAuthException catch (e) {
          print('[Firebase Auth Popup Exception] Code: ${e.code}, Message: ${e.message}');
          if (e.code == 'popup-blocked' || e.code == 'popup-closed-by-user') {
            await _auth.signInWithRedirect(googleProvider);
            return null;
          }
          rethrow;
        }
      }

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
      print('[Firebase Auth Exception] Code: ${e.code}, Message: ${e.message}');
      throw _mapFirebaseError(e);
    } catch (e) {
      print('[Google Sign-In Exception]: $e');
      throw e.toString().replaceFirst('Exception: ', '');
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
      case 'popup-blocked':
        return 'Sign-In popup was blocked by browser. Please allow popups or try again.';
      case 'popup-closed-by-user':
        return 'Google Sign-In popup was closed before completion.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for Google Sign-In in Firebase Console.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled in Firebase Console (Authentication -> Sign-in method -> Google).';
      case 'invalid-phone-number':
        return 'Enter a valid 10-digit mobile number.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'session-expired':
        return 'OTP code has expired. Please request a new OTP.';
      case 'too-many-requests':
        return 'Too many requests. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Internet connection unavailable. Please check your network.';
      default:
        return e.message ?? 'Authentication error (${e.code}). Please try again.';
    }
  }
}
