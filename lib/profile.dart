import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // İçerik etrafında boşluk
      child: Center(
        // İçeriği merkezi olarak yerleştirir
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Dikey olarak ortalar
          crossAxisAlignment:
              CrossAxisAlignment.start, // Yatay olarak sola hizalar
          children: [
            const CircleAvatar(
              radius: 50, // Profil resmi boyutu
              backgroundColor:
                  Color(0xFFFBB4D1), // Profil resmi arka plan rengi
              child: Icon(Icons.person,
                  size: 50, color: Colors.white), // Profil simgesi
            ),
            const SizedBox(height: 16), // Resim ile metin arasında boşluk
            const Text(
              'Nur Kozan', // Kullanıcı adı
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold), // Yazı stili
            ),
            const SizedBox(
                height: 8), // Kullanıcı adı ile alt metin arasında boşluk
            const Text(
              'Email: nurkozan@gmail.com', // Kullanıcı e-posta adresi
              style: TextStyle(fontSize: 16), // Yazı stili
            ),
            const SizedBox(height: 8), // E-posta ile alt metin arasında boşluk
            const Text(
              'Cilt Bakımı-Kombin🌸✨', // Kullanıcı hakkında bilgi
              style: TextStyle(fontSize: 16), // Yazı stili
            ),
            const SizedBox(height: 16), // Alt bölümler arasında boşluk
            ElevatedButton(
              onPressed: () {
                // Butona basıldığında çalışacak kod
              },
              child: const Text('Edit Profile'), // Buton yazısı
            ),
          ],
        ),
      ),
    );
  }
}
