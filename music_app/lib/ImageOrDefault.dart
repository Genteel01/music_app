import 'package:flutter/material.dart';
import 'dart:io';

class ImageOrDefault extends StatelessWidget {
  const ImageOrDefault({Key? key, required this.imagePath, required this.condition}) : super(key: key);

  final String imagePath;
  final bool condition;
  @override
  Widget build(BuildContext context) {
    return condition ? Image.asset("assets/images/music_note.jpg") : Image.file(File(imagePath));
  }
}
