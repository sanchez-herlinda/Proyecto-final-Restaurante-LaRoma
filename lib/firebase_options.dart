import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // 1. CAMBIO: Ahora retorna la configuración web en lugar de lanzar un error
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChvuuRO1q7F28d85jIGp2ZV3ayw9-6tL0',
    appId: '1:1008385277046:android:c348a94350caae5588b357',
    messagingSenderId: '1008385277046',
    projectId: 'bdcrudrestaurante',
    storageBucket: 'bdcrudrestaurante.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChvuuRO1q7F28d85jIGp2ZV3ayw9-6tL0',
    appId: '1:1008385277046:ios:AQUI_VA_EL_ID_DE_IOS',
    messagingSenderId: '1008385277046',
    projectId: 'bdcrudrestaurante',
    storageBucket: 'bdcrudrestaurante.appspot.com',
    iosBundleId: 'com.mycompany.proyectologin3u',
  );

  // 2. CAMBIO: Agregué la configuración para Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:
        'AIzaSyChvuuRO1q7F28d85jIGp2ZV3ayw9-6tL0', // Búscala en Firebase -> bdrestaurante App web -> Configuración
    appId:
        '1:1008385277046:web:AQUI_VA_EL_ID_WEB', // Búscalo en el mismo lugar, terminará en algo como web:1234abc...
    messagingSenderId: '1008385277046',
    projectId: 'bdcrudrestaurante',
    storageBucket: 'bdcrudrestaurante.appspot.com',
  );
}
