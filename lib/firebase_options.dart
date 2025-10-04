import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: "AIzaSyCYLibRheExUT63MA1NprDjgsPx82yvHUw",
    authDomain: "kiyashi-2d779.firebaseapp.com",
    projectId: "kiyashi-2d779",
    storageBucket: "kiyashi-2d779.firebasestorage.app",
    messagingSenderId: "286832259939",
    appId: "1:286832259939:web:c1948925e22fda26ee9956",
    measurementId: "G-9L0600RFYP",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCYLibRheExUT63MA1NprDjgsPx82yvHUw",
    authDomain: "kiyashi-2d779.firebaseapp.com",
    projectId: "kiyashi-2d779",
    storageBucket: "kiyashi-2d779.firebasestorage.app",
    messagingSenderId: "286832259939",
    appId: "1:286832259939:web:c1948925e22fda26ee9956",
    measurementId: "G-9L0600RFYP",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:demo',
    messagingSenderId: '123456789',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
    iosBundleId: 'com.example.kiyashi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:macos:demo',
    messagingSenderId: '123456789',
    projectId: 'demo-project',
    storageBucket: 'demo-project.appspot.com',
    iosBundleId: 'com.example.kiyashi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyCYLibRheExUT63MA1NprDjgsPx82yvHUw",
    authDomain: "kiyashi-2d779.firebaseapp.com",
    projectId: "kiyashi-2d779",
    storageBucket: "kiyashi-2d779.firebasestorage.app",
    messagingSenderId: "286832259939",
    appId: "1:286832259939:web:c1948925e22fda26ee9956",
    measurementId: "G-9L0600RFYP",
  );
}
