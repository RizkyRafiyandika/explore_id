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
    apiKey: 'AIzaSyDGQPfiF9ofzYW2venQvGV68ZgqZk1Gaq0',
    appId: '1:90951538094:web:3a76c30988d4193faee43f',
    messagingSenderId: '90951538094',
    projectId: 'explore-id-7b81e',
    authDomain: 'explore-id-7b81e.firebaseapp.com',
    storageBucket: 'explore-id-7b81e.firebasestorage.app',
    measurementId: 'G-K8JMD8DKVS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARoym-T2hcYqZ2AoiT3v1y2tD2VUbxpHs',
    appId: '1:90951538094:android:ae1637b2b634a3cfaee43f',
    messagingSenderId: '90951538094',
    projectId: 'explore-id-7b81e',
    storageBucket: 'explore-id-7b81e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWNlRdDpnEGb3nBp6HUUapoCBYSLwtTus',
    appId: '1:90951538094:ios:6b364d099e81cc7eaee43f',
    messagingSenderId: '90951538094',
    projectId: 'explore-id-7b81e',
    storageBucket: 'explore-id-7b81e.firebasestorage.app',
    iosBundleId: 'com.example.exploreId',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWNlRdDpnEGb3nBp6HUUapoCBYSLwtTus',
    appId: '1:90951538094:ios:6b364d099e81cc7eaee43f',
    messagingSenderId: '90951538094',
    projectId: 'explore-id-7b81e',
    storageBucket: 'explore-id-7b81e.firebasestorage.app',
    iosBundleId: 'com.example.exploreId',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDGQPfiF9ofzYW2venQvGV68ZgqZk1Gaq0',
    appId: '1:90951538094:web:7d8858da755d3ffdaee43f',
    messagingSenderId: '90951538094',
    projectId: 'explore-id-7b81e',
    authDomain: 'explore-id-7b81e.firebaseapp.com',
    storageBucket: 'explore-id-7b81e.firebasestorage.app',
    measurementId: 'G-EXZZPB51VN',
  );
}
