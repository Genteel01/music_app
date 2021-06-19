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


//TODO Cut some of the list.contains if it's possible to
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
    //clearAllData();
  }
  //Returns the path to the app's documents directory
  Future<String> getAppDocumentsDirectory() async
  {
    final savingDirectory = await getApplicationDocumentsDirectory();
    return savingDirectory.path;
  }
  //Adds a new directory to the places where you look for songs
  Future<void> getNewDirectory() async
  {
    //TODO remove this line once I stop testing with a system reset button
    appDocumentsDirectory = await getAppDocumentsDirectory();
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

  Future<void> fetch() async
  {
    print("BREAK________________________________________________________________");
    print("Start: " + DateTime.now().toString());
    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    appDocumentsDirectory = await getAppDocumentsDirectory();
    //clear any existing data we have gotten previously, to avoid duplicate data
    songs.clear();
    artists.clear();
    albums.clear();
    upNext.clear();
    currentlyPlaying = null;

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
    //If the albums file exists load everything from it
    if(File(appDocumentsDirectory + "/albums.txt").existsSync())
      {
        String albumFile = await File(appDocumentsDirectory + "/albums.txt").readAsString();
        var jsonFile = jsonDecode(albumFile);
        albums = Album.loadAlbumFile(jsonFile, appDocumentsDirectory);
      }
    //If the artists file exists load everything from it
    if(File(appDocumentsDirectory + "/artists.txt").existsSync())
    {
      String artistsFile = await File(appDocumentsDirectory + "/artists.txt").readAsString();
      var jsonFile = jsonDecode(artistsFile);
      artists = Artist.loadArtistFile(jsonFile);
    }
    //If the songs file exists load everything from it
    if(File(appDocumentsDirectory + "/songs.txt").existsSync())
    {
      String songsFile = await File(appDocumentsDirectory + "/songs.txt").readAsString();
      var jsonFile = jsonDecode(songsFile);
      songs = await Song.loadSongFile(jsonFile);
    }
    //If the album art directory doesn't exist create it
    if(!Directory(appDocumentsDirectory + "/albumart").existsSync())
    {
      Directory(appDocumentsDirectory + "/albumart").createSync();
    }
    //Sort the songs into artists and albums
    songs.forEach((element) {
      addToArtistsAndAlbums(element, null, null);
    });
    //Sort the song and album lists
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
    //Check for new songs within the directories you are looking at
    await Future.forEach(directoryPaths, (String directoryPath) async {
      //TODO wrap this in a try catch block to deal with the cases where it tries to map inaccessible system files
      var directoryMap = Directory(directoryPath).listSync(recursive: true);
      await Future.forEach(directoryMap, (FileSystemEntity filePath) async {
        if(filePath.path.endsWith("mp3") || filePath.path.endsWith("flac") || filePath.path.endsWith("m4a"))
        {
          if(!songs.any((element) => element.filePath == filePath.path))
            {
              Song newSong;
              Uint8List? albumArt;
              String albumYear = "Unknown Year";
              File file = File(filePath.path);
              await retriever.setFile(file);
              Metadata metaData = await retriever.metadata;
              if (retriever.albumArt != null) {
                albumArt = retriever.albumArt!;
              }
              if(metaData.year != null)
              {
                albumYear = metaData.year.toString();
              }
              newSong = Song(metaData, filePath.path, file.lastModifiedSync());
              songs.add(newSong);
              addToArtistsAndAlbums(newSong, albumArt, albumYear);
            }
        }
      });
    });
    //Sort the song and album lists
    sortByTrackName(songs);
    sortByAlbumName(albums);
    sortByArtistName(artists);
    artists.forEach((element) {
      sortByAlbumDiscAndTrackNumber(element.songs);
    });
    albums.forEach((element) {
      sortByNumber(element.songs);
    });
    //TODO somehow check for changes to album art and year (maybe by storing a last modified DateTime in the album too)
    //Remove all the artists and albums that have 0 songs in them
    //TODO Test this part by changing the directory that is used to search songs.
    for (int i = albums.length; i > 0; i--)
      {
        if(albums[i - 1].songs.length == 0)
          {
            albums.removeAt(i - 1);
            notifyListeners();
          }
      }
    for (int i = artists.length; i > 0; i--)
    {
      if(artists[i - 1].songs.length == 0)
      {
        artists.removeAt(i - 1);
        notifyListeners();
      }
    }
    //Save the songs, albums and artist lists
    String albumsJson = jsonEncode(Album.saveAlbumFile(albums, appDocumentsDirectory));
    File(appDocumentsDirectory + "/albums.txt").writeAsString(albumsJson);
    String artistsJson = jsonEncode(Artist.saveArtistFile(artists));
    File(appDocumentsDirectory + "/artists.txt").writeAsString(artistsJson);
    String songsJson = jsonEncode(Song.saveSongFile(songs));
    File(appDocumentsDirectory + "/songs.txt").writeAsString(songsJson);
    notifyListeners();
    print("End: " + DateTime.now().toString());
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

  Future<void> clearAllData() async
  {
    String documentStorage = await getAppDocumentsDirectory();
    if(File(documentStorage + "/albums.txt").existsSync())
    {
      File(documentStorage + "/albums.txt").delete();
    }
    //If the artists directory exists load everything from it, else create it
    if(File(documentStorage + "/artists.txt").existsSync())
    {
      File(documentStorage + "/artists.txt").delete();
    }
    //If the songs directory doesn't exist create it
    if(File(documentStorage + "/songs.txt").existsSync())
    {
      File(documentStorage + "/songs.txt").delete();
    }
    if(Directory(documentStorage + "/songs").existsSync())
    {
      Directory(documentStorage + "/songs").delete(recursive: true);
    }
    if(Directory(documentStorage + "/albums").existsSync())
      {
        Directory(documentStorage + "/albums").delete(recursive: true);
      }
    if(Directory(documentStorage + "/artists").existsSync())
      {
        Directory(documentStorage + "/artists").delete(recursive: true);
      }
    if(Directory(documentStorage + "/albumart").existsSync())
    {
      Directory(documentStorage + "/albumart").delete(recursive: true);
    }
  }

  void addToArtistsAndAlbums(Song newSong, Uint8List? albumArt, String? albumYear)
  {
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
    //TODO if the album is unknown album and you are making a new album set the album artist to various artists, if you are adding to unknown album ignore the album artist
    if(albums.any((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist))
    {
      albums.firstWhere((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist).songs.add(newSong);
    }
    else
    {
      Album newAlbum = Album(songs: [], name: newSong.album, albumArtist: newSong.albumArtist, albumArt: albumArt, year: albumYear == null ? "Unknown Year" : albumYear,);
      newAlbum.songs.add(newSong);
      albums.add(newAlbum);
    }
  }
}