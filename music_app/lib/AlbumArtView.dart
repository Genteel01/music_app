import 'dart:io';

import 'package:flutter/material.dart';

class AlbumArtView extends StatelessWidget {
  final String image;

  const AlbumArtView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
        appBar: AppBar(title: Text("Album Art")),
        //TODO wrap this with an interactive viewer
        body: Center(child: Hero(tag: "album_art", child: image == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(image)),))
    );
  }
}