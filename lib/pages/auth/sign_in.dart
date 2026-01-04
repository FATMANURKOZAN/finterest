import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // EKLENDİ

  SignInPage({super.key});

  // Firebase ile kullanıcı kaydı
  Future<void> signUp(BuildContext context) async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String username = _usernameController.text.trim();

      if (username.isEmpty) {
        _showErrorDialog(context, 'Lütfen kullanıcı adınızı girin.');
        return;
      }

      if (password != confirmPassword) {
        _showErrorDialog(context, 'Şifreler eşleşmiyor.');
        return;
      }

      // Firebase Authentication ile kullanıcı kaydı
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Kullanıcı UID'si
      String uid = credential.user!.uid;

      // Firestore'a kullanıcı bilgilerini kaydet
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
      });

      // Başarılıysa login sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  // Hata mesajı göstermek için fonksiyon
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Finterest'),
        backgroundColor: const Color(0xFFFBB4D1),
      ),
      body: Center(
        child: SingleChildScrollView(
          // Klavyeden kaynaklı overflow engellemek için
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kullanıcı Adı
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kullanıcı Adı',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email alanı
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Şifre alanı
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Şifre',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Şifre doğrulama
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Şifre Doğrula',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBB4D1),
                    ),
                    onPressed: () => signUp(context), // Firebase ile kayıt
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
