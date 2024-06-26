// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDaGsyF9cPrBVmF9OV-gl-yNbcAlm5UlfI',
    appId: '1:394358499617:web:ec9178b9d168bc2ffb3660',
    messagingSenderId: '394358499617',
    projectId: 'chat-app-5f9e4',
    authDomain: 'chat-app-5f9e4.firebaseapp.com',
    storageBucket: 'chat-app-5f9e4.appspot.com',
    measurementId: 'G-YJC963L01H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACUWPTf3FlX37CNndBTI80y184DjVaNTY',
    appId: '1:394358499617:android:e77112738dd1d48cfb3660',
    messagingSenderId: '394358499617',
    projectId: 'chat-app-5f9e4',
    storageBucket: 'chat-app-5f9e4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3SAwYrdHfKTPNC8MXX2jCGemnMhlfl3M',
    appId: '1:394358499617:ios:d684562467a31181fb3660',
    messagingSenderId: '394358499617',
    projectId: 'chat-app-5f9e4',
    storageBucket: 'chat-app-5f9e4.appspot.com',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3SAwYrdHfKTPNC8MXX2jCGemnMhlfl3M',
    appId: '1:394358499617:ios:9a62e22f3be118c3fb3660',
    messagingSenderId: '394358499617',
    projectId: 'chat-app-5f9e4',
    storageBucket: 'chat-app-5f9e4.appspot.com',
    iosBundleId: 'com.example.chatApp.RunnerTests',
  );
}
