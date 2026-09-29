// File generated for SIF Sentinel Oil India Limited
// Firebase project: sih26165-b7647
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZdKdly44HMpY-R3-y3cnL6IgzqOEwkOM',
    appId: '1:733324673190:web:7594845d6283a9f1d73105',
    messagingSenderId: '733324673190',
    projectId: 'sih26165-b7647',
    authDomain: 'sih26165-b7647.firebaseapp.com',
    storageBucket: 'sih26165-b7647.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZdKdly44HMpY-R3-y3cnL6IgzqOEwkOM',
    appId: '1:733324673190:android:5d5618b96fce7520bf3467',
    messagingSenderId: '733324673190',
    projectId: 'sih26165-b7647',
    storageBucket: 'sih26165-b7647.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZdKdly44HMpY-R3-y3cnL6IgzqOEwkOM',
    appId: '1:733324673190:ios:5d5618b96fce7520bf3467',
    messagingSenderId: '733324673190',
    projectId: 'sih26165-b7647',
    storageBucket: 'sih26165-b7647.firebasestorage.app',
    iosBundleId: 'SIF.sentinel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCZdKdly44HMpY-R3-y3cnL6IgzqOEwkOM',
    appId: '1:733324673190:ios:5d5618b96fce7520bf3467',
    messagingSenderId: '733324673190',
    projectId: 'sih26165-b7647',
    storageBucket: 'sih26165-b7647.firebasestorage.app',
    iosBundleId: 'SIF.sentinel',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZdKdly44HMpY-R3-y3cnL6IgzqOEwkOM',
    appId: '1:733324673190:web:7594845d6283a9f1d73105',
    messagingSenderId: '733324673190',
    projectId: 'sih26165-b7647',
    authDomain: 'sih26165-b7647.firebaseapp.com',
    storageBucket: 'sih26165-b7647.firebasestorage.app',
  );
}
