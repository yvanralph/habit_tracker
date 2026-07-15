// File placeholder - this normally gets generated automatically by the
// FlutterFire CLI. It exists here so the app compiles before you've
// connected a real Firebase project.
//
// To connect your real project, run this in your project root:
//   dart pub global activate flutterfire_cli
//   firebase login
//   flutterfire configure
//
// That command will ask you to pick (or create) a Firebase project and
// which platforms to support, then OVERWRITE this file with your real
// values automatically. You don't need to edit this file by hand.
//
// ignore_for_file: type=lint
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run `flutterfire configure` to add support for it.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBIQ-P2DEKCREvHEPNfmAMAGzRkE0lhDyE',
    appId: '1:740222781627:web:e26598b31b42f0f91e019e',
    messagingSenderId: '740222781627',
    projectId: 'habittracker-a5eb3',
    authDomain: 'habittracker-a5eb3.firebaseapp.com',
    storageBucket: 'habittracker-a5eb3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiazkoQbTI0COOolxlZ714v4XNUPcLMwg',
    appId: '1:740222781627:android:484b014edcf8f6111e019e',
    messagingSenderId: '740222781627',
    projectId: 'habittracker-a5eb3',
    storageBucket: 'habittracker-a5eb3.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCttFfsnAlzikVyfWUjexzoD9TqgK-5tMM',
    appId: '1:740222781627:ios:21df6652391277461e019e',
    messagingSenderId: '740222781627',
    projectId: 'habittracker-a5eb3',
    storageBucket: 'habittracker-a5eb3.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCttFfsnAlzikVyfWUjexzoD9TqgK-5tMM',
    appId: '1:740222781627:ios:21df6652391277461e019e',
    messagingSenderId: '740222781627',
    projectId: 'habittracker-a5eb3',
    storageBucket: 'habittracker-a5eb3.firebasestorage.app',
    iosBundleId: 'com.example.habitTracker',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );
}
