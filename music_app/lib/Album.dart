import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'Song.dart';

class Album{
  List<Song> songs;
  String id;
  String name;
  String albumArtist;
  String year;
  DateTime lastModified;
  String albumArt;
  Album(List<Song> songList, String albumName, String newAlbumArtist)
  :
      songs = songList,
      name = albumName,
      albumArtist = newAlbumArtist,
      year = "Unknown Year",
      lastModified = DateTime.fromMillisecondsSinceEpoch(0),
      albumArt = "",
      id = Uuid().v1();

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
      //TODO might not need Sync
      albumArt = directoryPath + id;
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
    //TODO might not need Sync
    albumArt = directoryPath + id;
    File(albumArt).writeAsBytesSync(newAlbumArt);
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        'albumArt' : albumArt,
        'id' : id
        //'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json, String directoryPath)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        albumArt = json['albumArt'],
        songs = [],
        id = json['id'],
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