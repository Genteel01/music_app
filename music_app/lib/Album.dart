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
      albumArt = directoryPath + id;
      File(albumArt).writeAsBytes(newAlbumArt);
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
    albumArt = directoryPath + id;
    File(albumArt).writeAsBytes(newAlbumArt);
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        'albumArt' : albumArt,
        'id' : id,
        'songs' : Song.songListToIdList(songs)
        //'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json, List<Song> allSongs)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        albumArt = json['albumArt'],
        songs = Song.idListToSongList(json['songs'].cast<String>(), allSongs),
        id = json['id'],
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']);

  //Function to turn a json file of several albums into a list of albums
  static List<Album> loadAlbumFile(List<dynamic> data, List<Song> allSongs)
  {
      List<Album> newAlbums = List<Album>.empty(growable: true);
      data.forEach((element) {
        newAlbums.add(Album.fromJson(element, allSongs));
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

  ///Converts an id list to a list of albums
  static List<Album> idListToAlbumList(List<String> ids, List<Album> allAlbums)
  {
    List<Album> newAlbumList = [];
    int length = allAlbums.length;
    //Look through all albums
    for(int i = 0; i < length; i++)
      {
        //If the album is in the id list, add it to the new album list
        if(ids.contains(allAlbums[i].id))
          {
            newAlbumList.add(allAlbums[i]);
          }
        //If you have found all the ids end the loop
        if(newAlbumList.length == ids.length)
        {
          break;
        }
      }
    return newAlbumList;
  }

  ///Converts a list of albums to a list of ids
  static List<String> albumListToIdList(List<Album> albums)
  {
    List<String> idList = [];
    albums.forEach((album) {
      idList.add(album.id);
    });
    return idList;
  }
}