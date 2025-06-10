import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCH-01YrElWehpaqPK1nS2fYPtc8ubEkvk",
    authDomain: "calendario-1a1f7.firebaseapp.com",
    projectId: "calendario-1a1f7",
    storageBucket: "calendario-1a1f7.appspot.com",
    messagingSenderId: "109058806644",
    appId: "1:109058806644:web:7cf6c9e52637859bdfd221",
    measurementId: "G-STP6YKE2MV",
  );
}
