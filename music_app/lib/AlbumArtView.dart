import 'dart:io';

import 'package:flutter/material.dart';

class AlbumArtView extends StatelessWidget {
  final String image;
  final String albumName;
  const AlbumArtView({Key? key, required this.image, required this.albumName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
        appBar: AppBar(title: Text("Album Art")),
        body: InteractiveViewer(child: Center(child: Hero(tag: albumName, child: image == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(image)),)))
    );
  }
}