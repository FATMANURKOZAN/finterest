// lib/main.dart içeriği

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core'u unutmayın!
import 'package:firebase_auth/firebase_auth.dart';
import 'package:artik_son/firebase_options.dart'; // firebase_options dosyasını import ediyoruz.
import 'package:artik_son/home.dart';
import 'package:artik_son/pages/auth/login.dart';

// UYARI: main.dart dosyasının en altındaki HomePage ve HomeContent sınıflarını SİLİN.
// Onlar artık home.dart dosyasında kullanılacak.

void main() async {
  // 1. Flutter Motorunun Hazırlanması (ASYNC işlemler için KRİTİK!)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Başlatılması
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finterest',
      // Ana widget olarak AuthCheck'i kullanıyoruz.
      // Bu, uygulamanın açılır açılmaz kullanıcı durumunu kontrol etmesini sağlar.
      home: AuthCheck(),
    );
  }
}

// Oturum Kontrol Widget'ı
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // authStateChanges() Stream'i, kullanıcının giriş/çıkış durumunu anlık takip eder.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Eğer bağlantı hala bekleniyorsa (Firebase'den cevap gelmemişse)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı giriş yapmışsa (User nesnesi varsa)
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage(); // home.dart'taki ana sayfaya yönlendir
        }

        // Kullanıcı giriş yapmamışsa
        return const LoginPage(); // login.dart'taki giriş sayfasına yönlendir
      },
    );
  }
}
