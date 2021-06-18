
import 'Song.dart';


class Artist{
  List<Song> songs;
  String name;
  String docPath;

  Artist({required this.songs, required this.name, this.docPath = ""});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'docPath': docPath,
      };

  Artist.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        docPath = json['docPath'],
        songs = [];
}

