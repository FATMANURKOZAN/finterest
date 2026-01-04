// lib/home.dart içeriği (Yeni Yapı)

import 'package:artik_son/pages/auth/login.dart';
import 'package:artik_son/photo_detail_page.dart';
import 'package:artik_son/profile.dart'; // profile.dart dosyasını import edin
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

  // HomeContent yerine, home.dart içinde yer alan Stream tabanlı GridView'ı kullanacağız.
  // ProfilePage'i ise lib/profile.dart dosyasından kullanacağız.
  final List<Widget> _pages = [
    HomeGridView(), // Stream tabanlı GridView (aşağıda)
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Çıkıştan sonra login sayfasına yönlendir
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, // tüm sayfa geçmişini siler
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finterest'),
        backgroundColor: const Color(0xFFFBB4D1),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Çıkış Yap"),
                    content: const Text("Hesabınızdan çıkış yapılsın mı?"),
                    actions: [
                      TextButton(
                        child: const Text("İptal"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text("Evet"),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _logout();
                        },
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFBB4D1),
        selectedItemColor: Colors.white, // Seçili rengi belirleyin
        unselectedItemColor:
            Colors.black54, // Seçili olmayanın rengini belirleyin
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

// ESKİ HomeContent'i SİLDİK. Yerine HomeGridView kullanacağız (HomeContent daha karmaşıktı).
// Sizin home.dart dosyanızdaki HomeGridView'ı, postları göstermek için kullanıyoruz.
class HomeGridView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fotoğraf yükleme butonu ve grid içeriğini birleştirir.
  @override
  Widget build(BuildContext context) {
    // Burada sizin home.dart dosyanızdaki StreamBuilder mantığını kullanıyoruz.
    return Column(
      children: [
        // Sadece HomeGridView'da fotoğraf yükleme butonu olsun
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _uploadPhoto(context),
            child: const Text("Upload Photo"),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestore
                .collection(
                    'posts') // Doğru koleksiyonu kullandığınızdan emin olun
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('Henüz yüklenmiş fotoğraf yok.'));
              }

              final posts = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoDetailPage(
                            photoUrl: post['photoUrl'],
                            username: post['username'] ?? 'Anonim',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              post['photoUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              post['username'] ?? 'Anonim',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Fotoğraf yükleme fonksiyonunu buraya taşıdık.
  Future<void> _uploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final _auth = FirebaseAuth.instance;
    final _storage = FirebaseStorage.instance;

    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fotoğraf yüklemek için giriş yapmalısınız.')),
      );
      return;
    }

    try {
      // Firestore’dan kullanıcı adı çek
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String username = userDoc['username'] ?? user.email ?? 'Anonim';

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('uploads/${user.uid}/$fileName');
      await ref.putFile(File(photo.path));

      String photoUrl = await ref.getDownloadURL();

      await _firestore.collection('posts').add({
        'photoUrl': photoUrl,
        'username': username,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf başarıyla yüklendi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: Fotoğraf yüklenemedi. $e')),
      );
    }
  }
}
