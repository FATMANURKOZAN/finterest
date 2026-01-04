import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String username = "Yükleniyor...";
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    if (currentUserId == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUserId).get();

    setState(() {
      username = userDoc['username'] ?? "Anonim";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hoş geldiniz, $username 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('posts')
                  .where('userId', isEqualTo: currentUserId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Henüz fotoğraf yüklemediniz."));
                }

                final posts = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post['photoUrl'],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
