import 'dart:typed_data';

import 'package:flutter/material.dart';

class AlbumArtView extends StatelessWidget {
  final Uint8List? image;

  const AlbumArtView({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
        appBar: AppBar(title: Text("Album Art")),
        //TODO wrap this with an interactive viewer
        body: Center(child: Hero(tag: "album_art", child: image == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(image!),))
    );
  }
}