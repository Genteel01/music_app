import 'dart:io';
import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  String name;
  String albumArtist;
  String year;
  DateTime lastModified;
  String albumArt;
  Album({required this.songs, required this.name, required this.albumArtist, required this.year, required this.lastModified, required this.albumArt});

  void updateAlbum(String newYear, String newArtist, Uint8List? newAlbumArt, DateTime newLastModified, String directoryPath)
  {
    if(albumArt != "")
      {
        if(File(albumArt).existsSync())
        {
          File(albumArt).delete();
        }
      }

    if(newAlbumArt != null)
    {
      //TODO use UUID and might not need Sync
      albumArt = directoryPath + year + albumArtist.substring(0, 1) + name.substring(0, 1);
      File(albumArt).writeAsBytesSync(newAlbumArt);
    }

    year = newYear;
    albumArtist = newArtist;
    lastModified = newLastModified;
  }

  void updateAlbumArt(String directoryPath, Uint8List newAlbumArt)
  {
    if(albumArt != "")
      {
        if(File(albumArt).existsSync())
        {
          File(albumArt).delete();
        }
      }
    //TODO use UUID and might not need Sync
    albumArt = directoryPath + year + albumArtist.substring(0, 1) + name.substring(0, 1);
    File(albumArt).writeAsBytesSync(newAlbumArt);
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        'albumArt' : albumArt
        //'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json, String directoryPath)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        albumArt = json['albumArt'],
        songs = [],
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']);

  //Function to turn a json file of several albums into a list of albums
  static List<Album> loadAlbumFile(List<dynamic> data, String directoryPath)
  {
      List<Album> newAlbums = List<Album>.empty(growable: true);
      data.forEach((element) {
        newAlbums.add(Album.fromJson(element, directoryPath));
      });
      return newAlbums;
  }

  //Function to turn a list of albums into a json file to be saved
  static List<Map<String, dynamic>> saveAlbumFile(List<Album> albumList, String directoryPath)
  {
    List<Map<String, dynamic>> newAlbums = List<Map<String, dynamic>>.empty(growable: true);
    albumList.forEach((element) {
      newAlbums.add(element.toJson());
    });
    return newAlbums;
  }
}