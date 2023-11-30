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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCo6kjD66cQzh17xsURMQcbIkV0pRcjDAg',
    appId: '1:237629142128:web:788078ccc14fa1e47630b5',
    messagingSenderId: '237629142128',
    projectId: 'kiranashopy-79d19',
    authDomain: 'kiranashopy-79d19.firebaseapp.com',
    storageBucket: 'kiranashopy-79d19.appspot.com',
    measurementId: 'G-QKKPXTJJDC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATpPiaN1yS3zHcCgjyT4BOt0z496e0RU0',
    appId: '1:237629142128:android:72d0346290369a827630b5',
    messagingSenderId: '237629142128',
    projectId: 'kiranashopy-79d19',
    storageBucket: 'kiranashopy-79d19.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQ_jHEEDYU5RqZyouj5nk4-qSDWnaFT4Q',
    appId: '1:237629142128:ios:be54ef329dc087c37630b5',
    messagingSenderId: '237629142128',
    projectId: 'kiranashopy-79d19',
    storageBucket: 'kiranashopy-79d19.appspot.com',
    androidClientId: '237629142128-if0uc1c8a3hl1iecau9l2tp24i9ueiin.apps.googleusercontent.com',
    iosClientId: '237629142128-gia27aee39elkpke7bmgvnem16bnu132.apps.googleusercontent.com',
    iosBundleId: 'com.tecmanic.gogrocer.user',
  );
}
