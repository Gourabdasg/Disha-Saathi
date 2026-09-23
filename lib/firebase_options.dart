// File generated for Firebase project: disha-saathi (Disha saathi)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project disha-saathi.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_disha_saathi_web_key_stub',
    appId: '1:109823487234:web:disha_saathi_app_id',
    messagingSenderId: '109823487234',
    projectId: 'disha-saathi',
    authDomain: 'disha-saathi.firebaseapp.com',
    storageBucket: 'disha-saathi.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_disha_saathi_android_key_stub',
    appId: '1:109823487234:android:disha_saathi_app_id',
    messagingSenderId: '109823487234',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_disha_saathi_ios_key_stub',
    appId: '1:109823487234:ios:disha_saathi_app_id',
    messagingSenderId: '109823487234',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.appspot.com',
    iosBundleId: 'com.aialchemists.dishaSaathi',
  );
}
