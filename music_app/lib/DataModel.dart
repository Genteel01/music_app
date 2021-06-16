import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'Album.dart';
import 'Artist.dart';
import 'Song.dart';
//TODO https://pub.dev/packages/audio_service
//TODO https://pub.dev/packages/just_audio
//TODO https://pub.dev/packages/assets_audio_player
class DataModel extends ChangeNotifier {

  //added this
  bool loading = false;
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];

  List<Song> upNext = [];
  Song? currentlyPlaying;

  //replaced this
  DataModel()
  {
    fetch();
  }

  //TODO to check for changes on startup store the old file map and check if the new one is different. If it is, get all the songs at the different spots, then sort all the lists again
  //added this
  Future<void> fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    songs.clear();
    artists.clear();
    albums.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    var retriever = new MetadataRetriever();
    if(directoryPath != null)
    {
      //TODO wrap this in a try catch block to deal with the cases where it tries to map inaccessible system files
      var directoryMap = Directory(directoryPath).listSync(recursive: true);
      await Future.forEach(directoryMap, (FileSystemEntity filePath) async {
        if(filePath.path.endsWith("mp3") || filePath.path.endsWith("flac") || filePath.path.endsWith("m4a"))
        {
          File file = File(filePath.path);
          await retriever.setFile(file);
          Metadata metaData = await retriever.metadata;
          Uint8List? albumArt;
          if(retriever.albumArt != null)
            {
              albumArt = retriever.albumArt!;
            }
          Song newSong = Song(metaData, filePath.path);
          songs.add(newSong);
          if(artists.any((element) => element.name == newSong.artist))
            {
                artists.firstWhere((element) => element.name == newSong.artist).songs.add(newSong);
            }
          else
            {
              Artist newArtist = Artist(songs: [], name: newSong.artist);
              newArtist.songs.add(newSong);
              artists.add(newArtist);
            }
          if(albums.any((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist))
          {
            albums.firstWhere((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist).songs.add(newSong);
          }
          else
            {
              Album newAlbum = Album(songs: [], name: newSong.album, albumArtist: newSong.albumArtist, albumArt: albumArt, year: metaData.year == null ? "Unknown Year" : metaData.year.toString(),);
              newAlbum.songs.add(newSong);
              albums.add(newAlbum);
            }
          //TODO what if I save all the album arts to a file and just have the albums contain the path to that file. That way I would maybe use even less memory (might be too slow and not needed though)
        }
      });
    }

    sortByTrackName(songs);
    sortByAlbumName(albums);
    sortByArtistName(artists);
    artists.forEach((element) {
      sortByTrackName(element.songs);
    });
    albums.forEach((element) {
      sortByNumber(element.songs);
    });
    loading = false;
    notifyListeners();
  }
  //Sorts a list of songs by the disc and track numbers
  void sortByNumber(List<Song> songList)
  {
    songList.sort((a, b) => a.discNumber.compareTo(b.discNumber) == 0 ? (a.trackNumber.compareTo(b.trackNumber)) : a.discNumber.compareTo(b.discNumber));
  }
  //Sorts a list of songs by the track name
  void sortByTrackName(List<Song> songList)
  {
    songList.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
  }
  //Sorts a list of albums by name
  void sortByAlbumName (List<Album> albumList)
  {
    albumList.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
  }
  //Sorts a list of artists by name
  void sortByArtistName (List<Artist> artistList)
  {
    artistList.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
  }

  Uint8List? getAlbumArt(Song song)
  {
    return albums.firstWhere((element) => song.albumArtist == element.albumArtist && song.album == element.name).albumArt;
  }
  //Function that sets the currently playing song
  void setCurrentlyPlaying(Song song, List<Song> futureSongs)
  {
    currentlyPlaying = song;
    upNext.clear();
    upNext.addAll(futureSongs);
    upNext.remove(currentlyPlaying);
    notifyListeners();
  }
}