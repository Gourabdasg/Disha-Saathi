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
    apiKey: 'AIzaSyAytmixk6ZZ0dQgpn6-xw_C2K0gcyYQ3nI',
    appId: '1:610010711984:web:disha_saathi_web_app_id',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    authDomain: 'disha-saathi.firebaseapp.com',
    storageBucket: 'disha-saathi.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAytmixk6ZZ0dQgpn6-xw_C2K0gcyYQ3nI',
    appId: '1:610010711984:android:744370baae01ccb6e43875',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAytmixk6ZZ0dQgpn6-xw_C2K0gcyYQ3nI',
    appId: '1:610010711984:ios:disha_saathi_ios_app_id',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.firebasestorage.app',
    iosBundleId: 'com.aialchemists.dishaSaathi',
  );
}
