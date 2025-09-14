import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

class PanoramaViewer extends StatelessWidget {
  final String imageUrl;

  const PanoramaViewer({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("360° Image Viewer")),
      body: Panorama(
        child: Image.network(imageUrl),
      ),
    );
  }
}
