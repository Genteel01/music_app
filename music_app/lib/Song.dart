import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:uuid/uuid.dart';

class Song {
  String filePath;
  String name;
  String artist;
  String albumName;
  int duration;
  String albumArtist;
  int discNumber;
  int trackNumber;
  DateTime lastModified;
  String album;
  String year;
  String id;

  Song(Metadata metadata, String songFilePath, DateTime modified)
  :
    name = metadata.trackName == null ? songFilePath.split("/").last.split(".").first : metadata.trackName!,
    artist = metadata.trackArtistNames == null ? "Unknown Artist" : artistString(metadata.trackArtistNames!),
    albumName = metadata.albumName == null ? "Unknown Album" : metadata.albumName!,
    year = metadata.year == null ? "Unknown Year" : metadata.year.toString(),
    albumArtist = metadata.albumArtistName == null ? "Unknown Artist" : metadata.albumArtistName!,
    discNumber = metadata.discNumber == null ? 1 : metadata.discNumber!,
    trackNumber = metadata.trackNumber == null ? 1 : metadata.trackNumber!,
    //year = metadata.year == null ? "Unknown Year" : metadata.year.toString(),
    duration = metadata.trackDuration == null ? 0 : metadata.trackDuration!,
    filePath = songFilePath,
    lastModified = modified,
    album = "",
    id = Uuid().v1();
    //albumArt = songAlbumArt;

  void updateSong(Metadata metadata, DateTime modified)
  {
    name = metadata.trackName == null ? filePath.split("/").last.split(".").first : metadata.trackName!;
    artist = metadata.trackArtistNames == null ? "Unknown Artist" : artistString(metadata.trackArtistNames!);
    albumName = metadata.albumName == null ? "Unknown Album" : metadata.albumName!;
    year = metadata.year == null ? "Unknown Year" : metadata.year.toString();
    albumArtist = metadata.albumArtistName == null ? "Unknown Artist" : metadata.albumArtistName!;
    discNumber = metadata.discNumber == null ? 1 : metadata.discNumber!;
    trackNumber = metadata.trackNumber == null ? 1 : metadata.trackNumber!;
    duration = metadata.trackDuration == null ? 0 : metadata.trackDuration!;
    lastModified = modified;
  }

  static String artistString(List<String?> originalList)
  {
    String artist = "";
    for (int i = 0; i < originalList.length; i++) {
      if (i != 0) {
        artist += "/";
      }
      artist += originalList[i]!;
    }
    return artist;
  }

  //Function to return the duration as a human readable string
  String durationString()
  {
    return duration == 0 ? "Unknown" :
    ((duration / 1000) / 60).floor().toString() + (((duration / 1000) % 60).floor() < 10 ? ":0" : ":") + ((duration / 1000) % 60).floor().toString();
  }

  Song.fromJson(Map<String, dynamic> json,)
      :
        name = json['name'],
        artist = json['artist'],
        albumName = json['album'],
        duration = json['duration'],
        albumArtist = json['albumArtist'],
        discNumber = json['discNumber'],
        trackNumber = json['trackNumber'],
        filePath = json['filePath'],
        year = json['year'],
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
        album = json['album'],
        id = json['id'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'artist': artist,
        'albumName' : albumName,
        'duration' : duration,
        'albumArtist' : albumArtist,
        'discNumber': discNumber,
        'trackNumber' : trackNumber,
        'filePath' : filePath,
        'year' : year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        'album' : album,
        'id' : id
      };

  //Function to turn a json file of several songs into a list of songs
  static Future<List<Song>> loadSongFile(List<dynamic> data) async
  {
    List<Song> newSongs = List<Song>.empty(growable: true);
    await Future.forEach(data, (dynamic element) async {
      Song newSong = Song.fromJson(element);
      //Check if the song still exists
      if(File(newSong.filePath).existsSync())
      {
        newSongs.add(Song.fromJson(element));
      }
    });
    return newSongs;
  }

  //Function to turn a list of songs into a json file to be saved
  static List<Map<String, dynamic>> saveSongFile(List<Song> songList)
  {
    List<Map<String, dynamic>> newSongs = List<Map<String, dynamic>>.empty(growable: true);
    songList.forEach((element) {
      newSongs.add(element.toJson());
    });
    return newSongs;
  }

  ///Converts and id list to a list of songs
  static List<Song> idListToSongList(List<String> ids, List<Song> allSongs)
  {
    List<Song> newSongList = [];
    int length = allSongs.length;
    //Look through all songs
    for(int i = 0; i < length; i++)
    {
      //If the song is in the id list, add it to the new song list
      if(ids.contains(allSongs[i].id))
      {
        newSongList.add(allSongs[i]);
      }
      //If you have found all the ids end the loop
      if(newSongList.length == ids.length)
      {
        break;
      }
    }
    return newSongList;
  }

  ///Converts a song list to a list of those song's ids
  static List<String> songListToIdList(List<Song> songs)
  {
    List<String> idList = [];
    songs.forEach((song) {
      idList.add(song.id);
    });
    return idList;
  }
}
