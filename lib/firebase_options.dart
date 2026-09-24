// File generated for Firebase project: disha-saathi (Disha saathi)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for project disha-saathi.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for Android currently. '
      'Run `flutterfire configure` to add Web/iOS support.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAytmixk6ZZ0dQgpn6-xw_C2K0gcyYQ3nI',
    appId: '1:610010711984:android:744370baae01ccb6e43875',
    messagingSenderId: '610010711984',
    projectId: 'disha-saathi',
    storageBucket: 'disha-saathi.firebasestorage.app',
  );
}
