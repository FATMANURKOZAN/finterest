import 'package:artik_son/pages/auth/login.dart';
import 'package:artik_son/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Alt gezinme çubuğu için sayfalar
  final List<Widget> _pages = [
    HomeContent(), // Ana Sayfa İçeriği
    ProfilePage(), // Profil Sayfası (profile.dart'taki sınıf)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Seçilen sekmeye göre index güncellenir
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finterest'),
        backgroundColor: const Color(0xFFFBB4D1), // Pembe renk
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Çıkış simgesi
            onPressed: () {
              // Çıkış işlemi ve login sayfasına yönlendirme
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            tooltip: 'Logout', // İpucu metni
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Seçilen sayfa gösterilir
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFBB4D1),
        currentIndex: _selectedIndex, // Mevcut seçili sekme
        onTap: _onItemTapped, // Tıklama olayını yöneten fonksiyon
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Fotoğraf yükleme fonksiyonu
  Future<void> uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_photos/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageRef.putFile(file);

      // Yükleme tamamlandığında fotoğraf URL'sini al
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Firebase Firestore'a kaydet
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Firestore'da kullanıcı verisini kaydet
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {
            'photoUrl': downloadUrl,
            'username': FirebaseAuth.instance.currentUser!.email,
          },
          SetOptions(
              merge: true)); // merge: true, mevcut veriye ekleme yapar, silmez
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user data found'));
        }

        String photoUrl =
            snapshot.data?['photoUrl'] ?? ''; // Eğer fotoğraf yoksa boş string

        return Column(
          children: [
            ElevatedButton(
              onPressed:
                  uploadPhoto, // Butona basıldığında fotoğraf yükleme işlemi başlatılır
              child: const Text("Upload Photo"),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(6, (index) {
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: photoUrl.isNotEmpty
                              ? Image.network(photoUrl, fit: BoxFit.cover)
                              : const Center(child: Text('No image')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 15,
                                backgroundColor: Color(0xFFFBB4D1),
                                child: Icon(Icons.person,
                                    size: 15, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  snapshot.data?['username'] ?? 'Unknown user'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
