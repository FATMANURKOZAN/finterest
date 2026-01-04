import 'package:flutter/material.dart';

class PhotoDetailPage extends StatelessWidget {
  final String photoUrl;
  final String username;

  const PhotoDetailPage({
    super.key,
    required this.photoUrl,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$username Fotoğrafı'),
        backgroundColor: const Color(0xFFFBB4D1),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                photoUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Fotoğraf yüklenirken bir hata oluştu.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
