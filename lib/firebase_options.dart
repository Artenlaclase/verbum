// File generated for Verbum Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5XXTP7JjbjSmAEbMTmjNwFx2C3sZLDa0',
    appId: '1:255475933508:web:c63b71d1c19a3069eff711',
    messagingSenderId: '255475933508',
    projectId: 'verbumv1',
    authDomain: 'verbumv1.firebaseapp.com',
    storageBucket: 'verbumv1.firebasestorage.app',
    measurementId: 'G-RFRTFZDMQ7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5XXTP7JjbjSmAEbMTmjNwFx2C3sZLDa0',
    appId: '1:255475933508:android:c63b71d1c19a3069eff711',
    messagingSenderId: '255475933508',
    projectId: 'verbumv1',
    storageBucket: 'verbumv1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5XXTP7JjbjSmAEbMTmjNwFx2C3sZLDa0',
    appId: '1:255475933508:ios:c63b71d1c19a3069eff711',
    messagingSenderId: '255475933508',
    projectId: 'verbumv1',
    storageBucket: 'verbumv1.firebasestorage.app',
    iosBundleId: 'com.example.verbum',
  );
}
