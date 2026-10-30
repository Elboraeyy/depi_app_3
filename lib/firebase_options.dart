// Generated from the DEPI Firebase project configuration.
// Keep this file in sync with the Firebase app registered for Android.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured yet. Run flutterfire configure to add it.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is currently configured for Android and iOS only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2rLw3AQ2pOv6sUI_MqHqSzMrS9jr9x-8',
    appId: '1:63857879012:android:c2cc343ee21d6394f489f1',
    messagingSenderId: '63857879012',
    projectId: 'depi-1-60ebd',
    storageBucket: 'depi-1-60ebd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqK8MK469JyAE1xqXn6JZ_uunacYQ8zNE',
    appId: '1:63857879012:ios:85001278912cb775f489f1',
    messagingSenderId: '63857879012',
    projectId: 'depi-1-60ebd',
    storageBucket: 'depi-1-60ebd.firebasestorage.app',
    iosBundleId: 'com.example.outofsession',
  );
}
