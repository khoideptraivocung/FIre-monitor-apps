import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the app.
/// Replace placeholder fields with your custom credentials or run 'flutterfire configure' to overwrite.
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
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3FHF87-2SDs7o3-xuggumYIhv5yMwxD8',
    appId: '1:595943829773:web:68f40ba28dde1fa3db0044',
    messagingSenderId: '595943829773',
    projectId: 'finalproject-3f736',
    authDomain: 'finalproject-3f736.firebaseapp.com',
    databaseURL: 'https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'finalproject-3f736.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8tZgHP94Rpgjc-z1QpsmU0q9dgdgV3gc',
    appId: '1:595943829773:android:8bc5fa30d1eff739db0044',
    messagingSenderId: '595943829773',
    projectId: 'finalproject-3f736',
    databaseURL: 'https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'finalproject-3f736.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAV-hUBywi7zdn10dZYBnTKOCnSTsRdQHg',
    appId: '1:595943829773:ios:cc005c292f0ae7fbdb0044',
    messagingSenderId: '595943829773',
    projectId: 'finalproject-3f736',
    databaseURL: 'https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'finalproject-3f736.firebasestorage.app',
    iosBundleId: 'com.example.fireMonitorApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAV-hUBywi7zdn10dZYBnTKOCnSTsRdQHg',
    appId: '1:595943829773:ios:cc005c292f0ae7fbdb0044',
    messagingSenderId: '595943829773',
    projectId: 'finalproject-3f736',
    databaseURL: 'https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'finalproject-3f736.firebasestorage.app',
    iosBundleId: 'com.example.fireMonitorApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3FHF87-2SDs7o3-xuggumYIhv5yMwxD8',
    appId: '1:595943829773:web:68f40ba28dde1fa3db0044',
    messagingSenderId: '595943829773',
    projectId: 'finalproject-3f736',
    authDomain: 'finalproject-3f736.firebaseapp.com',
    databaseURL: 'https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'finalproject-3f736.firebasestorage.app',
  );
}
