// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCl_iYijcOigoHG5syMOKQlLCgvZhwNli4',
    appId: '1:498616526713:web:3ab6a791e1fdd09e5e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    authDomain: 'despro-8d0d4.firebaseapp.com',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
    measurementId: 'G-CWFXQRCY49',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDA2vmjVcwYpVoXknG_GBftuo1sgPfRqcs',
    appId: '1:498616526713:android:92ab0c31a2d930685e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5L8iwviGKErpJCFbztXjuY8kl40oKnYQ',
    appId: '1:498616526713:ios:d0db11651a40ade95e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
    iosBundleId: 'com.example.webDespro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5L8iwviGKErpJCFbztXjuY8kl40oKnYQ',
    appId: '1:498616526713:ios:d0db11651a40ade95e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
    iosBundleId: 'com.example.webDespro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCl_iYijcOigoHG5syMOKQlLCgvZhwNli4',
    appId: '1:498616526713:web:f635399bc26b12d35e31a8',
    messagingSenderId: '498616526713',
    projectId: 'despro-8d0d4',
    authDomain: 'despro-8d0d4.firebaseapp.com',
    storageBucket: 'despro-8d0d4.firebasestorage.app',
    measurementId: 'G-GTGRBVK4V5',
  );
}