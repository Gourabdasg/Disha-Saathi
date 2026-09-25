// File generated for Firebase project: disha-saathi (Disha saathi)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project disha-saathi.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are configured for Android and Web currently.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC54N8OIgiiqJSmX2GBATYXeMTqkHEOHo',
    appId: '1:610010711984:web:260b8c9b65805ec2e43875',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    authDomain: 'disha-saathi.firebaseapp.com',
    storageBucket: 'disha-saathi.firebasestorage.app',
    measurementId: 'G-57PLBXT6P0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAytmixk6ZZ0dQgpn6-xw_C2K0gcyYQ3nI',
    appId: '1:610010711984:android:744370baae01ccb6e43875',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.firebasestorage.app',
  );
}
