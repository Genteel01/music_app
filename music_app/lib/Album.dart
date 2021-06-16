import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  Uint8List? albumArt;
  String name;
  String albumArtist;
  String year;
  Album({required this.songs, required this.name, required this.albumArtist, this.albumArt, required this.year});
}