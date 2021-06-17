
import 'Song.dart';


class Artist{
  List<Song> songs;
  String name;
  String docPath;
  Artist({required this.songs, required this.name, this.docPath = ""});
}