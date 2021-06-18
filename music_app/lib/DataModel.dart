import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path_provider/path_provider.dart';

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

  List<String> directoryPaths = [];

  String appDocumentsDirectory = "";
  //replaced this
  DataModel()
  {
    fetch();
  }

  Future<String> getAppDocumentsDirectory() async
  {
    final savingDirectory = await getApplicationDocumentsDirectory();
    return savingDirectory.path;
  }

  Future<void> getNewDirectory() async
  {
    //Have the user pick a new location to look for music
    String? newDirectoryPath = await FilePicker.platform.getDirectoryPath();
    if(newDirectoryPath != null)
    {
      directoryPaths.add(newDirectoryPath);
    }
    //Save this location to the file
    String directoryPathsJson = jsonEncode(directoryPaths);
    File(appDocumentsDirectory + "/music_locations.txt").writeAsString(directoryPathsJson);
  }
  //TODO to check for changes on startup store the old file map and check if the new one is different. If it is, get all the songs at the different spots, then sort all the lists again
  //added this
  Future<void> fetch() async
  {
    appDocumentsDirectory = await getAppDocumentsDirectory();
    //clear any existing data we have gotten previously, to avoid duplicate data
    songs.clear();
    artists.clear();
    albums.clear();
    upNext.clear();
    currentlyPlaying = null;

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //If you haven't already got locations to look for music
    if(!File(appDocumentsDirectory + "/music_locations.txt").existsSync())
      {
          await getNewDirectory();
      }
    //If you have already got locations then load them.
    else
      {
        directoryPaths = jsonDecode(File(appDocumentsDirectory + "/music_locations.txt").readAsStringSync()).cast<String>();
      }
    var retriever = new MetadataRetriever();
    //If the albums directory exists load everything from it, else create it
    if(Directory(appDocumentsDirectory + "/albums").existsSync())
      {

      }
    else
      {
        Directory(appDocumentsDirectory + "/albums").createSync();
      }
    //If the artists directory exists load everything from it, else create it
    if(Directory(appDocumentsDirectory + "/artists").existsSync())
    {
      var artistsDirectory = Directory(appDocumentsDirectory + "/artists").listSync();
      await Future.forEach(artistsDirectory, (FileSystemEntity filePath) async {
        String artistString = await File(filePath.path).readAsString();
        var jsonFile = jsonDecode(artistString);
        Artist newArtist = Artist.fromJson(jsonFile);
        artists.add(newArtist);
      });
    }
    else
    {
      Directory(appDocumentsDirectory + "/artists").createSync();
    }
    //If the songs directory doesn't exist create it
    if(!Directory(appDocumentsDirectory + "/songs").existsSync())
    {
      Directory(appDocumentsDirectory + "/songs").createSync();
    }
    await Future.forEach(directoryPaths, (String directoryPath) async {
      //TODO wrap this in a try catch block to deal with the cases where it tries to map inaccessible system files
      var directoryMap = Directory(directoryPath).listSync(recursive: true);
      await Future.forEach(directoryMap, (FileSystemEntity filePath) async {
        if(filePath.path.endsWith("mp3") || filePath.path.endsWith("flac") || filePath.path.endsWith("m4a"))
        {
          //TODO IF FILE_IN_DOCUMENTS_DIRECTORY EXISTS LOAD FROM THAT FILE
          //TODO ELSE GENERATE NEW SONG (LIKE THIS)
          File file = File(filePath.path);
          await retriever.setFile(file);
          Metadata metaData = await retriever.metadata;
          Uint8List? albumArt;
          if(retriever.albumArt != null)
          {
            albumArt = retriever.albumArt!;
          }
          Song newSong = Song(metaData, filePath.path);
          //TODO Make the new local file (can happen in the background, so doesn't need to await)
          //TODO END ELSE
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
            newArtist.docPath = "/artists/" + newArtist.name.replaceAll("/", "_");
            String artistJson = jsonEncode(newArtist.toJson());
            File(appDocumentsDirectory + newArtist.docPath).writeAsString(artistJson);
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
            //TODO Save the album to a local file
          }
          //TODO REMOVE ALL THE ARTISTS AND ALBUMS WITH 0 SONGS
          //TODO ALSO REMOVE THEIR LOCAL FILES (Don't await this part, it's fine if it happens in the background)
          //TODO Go through each saved song and if it doesn't exist in a song file delete its local file (perfectly fine to not await this too)
          //TODO what if I save all the album arts to a file and just have the albums contain the path to that file. That way I would maybe use even less memory (might be too slow and not needed though)
        }
      });
    });

    sortByTrackName(songs);
    sortByAlbumName(albums);
    sortByArtistName(artists);
    artists.forEach((element) {
      sortByAlbumDiscAndTrackNumber(element.songs);
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
  //Sorts a list of songs by album, then disc number, then track number
  void sortByAlbumDiscAndTrackNumber(List<Song> songList)
  {
    songList.sort((a, b) => a.album.compareTo(b.album) == 0 ? (a.discNumber.compareTo(b.discNumber) == 0 ? (a.trackNumber.compareTo(b.trackNumber)) : a.discNumber.compareTo(b.discNumber)): a.album.compareTo(b.album));
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
    //TODO at this point upNext needs to move elements so currentlyPlaying is the first element in the list (Maybe only if shuffle == false?)
    upNext.remove(currentlyPlaying);
    notifyListeners();
  }
}