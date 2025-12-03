// lib/screens/fullscreen_image_viewer.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String heroTag; // For the smooth animation

  const FullscreenImageViewer({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The main photo view that allows zooming and panning
          PhotoView(
            imageProvider: FileImage(File(imagePath)),
            heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
          ),
          // A simple "close" button at the top
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

