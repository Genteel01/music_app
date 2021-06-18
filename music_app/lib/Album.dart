import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  Uint8List? albumArt;
  String name;
  String albumArtist;
  String year;
  String docPath;
  Album({required this.songs, required this.name, required this.albumArtist, this.albumArt, required this.year, this.docPath = ""});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'docPath': docPath,
        'albumArtist': albumArtist,
        'year': year,
        'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        docPath = json['docPath'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        songs = [],
        albumArt = convertImage(json['albumArt']);

  static Uint8List? convertImage(List<dynamic>? source)
  {
    if(source == null)
      {
        return null;
      }
    List<int> list = source.cast();
    //List<int> list = utf8.encode(source[0].toString());
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }
}