import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';



import 'Album.dart';
import 'Artist.dart';
import 'Playlist.dart';
import 'Settings.dart';
import 'Song.dart';


enum LoopType {
  none,
  loop,
  singleSong,
}
//TODO Cut some of the list.contains if it's possible to

//TODO for faster loading try storing songs in the album and artist files too, and loading them into the song list too, then do a songs.reduce() to get rid of duplicates after loading

//TODO it might be even faster to store all the data in a single text file
//This might not actually be faster, and might not be worth the effort (also it would use a lot more memory and more storage space)
class DataModel extends ChangeNotifier {

  bool loading = false;
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Playlist> playlists = [];

  Settings settings = Settings(upNext: [], shuffle: false, loop: LoopType.none, playingIndex: 0, startingIndex: 0, songPaths: [], originalSongPaths: [], originalUpNext: []);

  List<String> directoryPaths = [];

  String appDocumentsDirectory = "";

  final audioPlayer = AudioPlayer();

  List<int> selectedIndices = [];
  Type selectionType = Song;

  List<Object> searchResults = [];


  Random randomNumbers = new Random();
  getSearchResults(String searchText)
  {
    searchResults.clear();
    if(searchText != "") {
      artists.forEach((element) {
        if (element.name.toUpperCase().contains(searchText.toUpperCase())) {
          searchResults.add(element);
        }
      });
      albums.forEach((element) {
        if (element.name.toUpperCase().contains(searchText.toUpperCase()) ||
            element.albumArtist.toUpperCase().contains(
                searchText.toUpperCase())) {
          searchResults.add(element);
        }
      });
      songs.forEach((element) {
        if (element.name.toUpperCase().contains(searchText.toUpperCase()) ||
            element.artist.toUpperCase().contains(searchText.toUpperCase()) ||
            element.album.toUpperCase().contains(searchText.toUpperCase()) ||
            element.albumArtist.toUpperCase().contains(
                searchText.toUpperCase())) {
          searchResults.add(element);
        }
      });
    }
    notifyListeners();
  }

  List<Song> buildUpNext()
  {
    List<Song> newList = [];
    searchResults.forEach((element) {
      if(element.runtimeType == Song)
      {
        newList.add(element as Song);
      }
    });
    return newList;
  }

  clearSelections()
  {
    selectedIndices.clear();
    notifyListeners();
  }

  removeFromPlaylist(Playlist playlist)
  {
    selectedIndices.sort((a, b) => b.compareTo(a));
    selectedIndices.forEach((element) {
      playlist.songs.removeAt(element);
    });
    clearSelections();
    notifyListeners();
    savePlaylists();
  }
  //Returns true if all the values in the selection type you are working with are selected, false otherwise
  bool returnAllSelected(Album? album, Artist? artist, Playlist? playlist)
  {
    if(selectedIndices.length > 0) {
      if (selectionType == Song) {
        if (album != null) {
          return selectedIndices.length == album.songs.length;
        }
        else if (artist != null) {
          return selectedIndices.length == artist.songs.length;
        }
        else if(playlist != null)
          {
            return selectedIndices.length == playlist.songs.length;
          }
        else {
          return selectedIndices.length == songs.length;
        }
      }
      if (selectionType == Album) {
        return selectedIndices.length == albums.length;
      }
      if (selectionType == Artist) {
        return selectedIndices.length == artists.length;
      }
      if (selectionType == Playlist) {
        return selectedIndices.length == playlists.length;
      }
    }
    return false;
  }
  
  //Selects all the values for the selection type you are currently working with
  void selectAll(Album? album, Artist? artist, Playlist? playlist)
  {
    clearSelections();
    switch (selectionType)
    {
      case Album: selectedIndices.addAll(List<int>.generate(albums.length, (i) => i));
              break;
      case Artist: selectedIndices.addAll(List<int>.generate(artists.length, (i) => i));
              break;
      case Song: if(album != null)
                {
                  selectedIndices.addAll(List<int>.generate(album.songs.length, (i) => i));
                }
              else if(artist != null)
                {
                  selectedIndices.addAll(List<int>.generate(artist.songs.length, (i) => i));
                }
              else if(playlist != null)
                {
                  selectedIndices.addAll(List<int>.generate(playlist.songs.length, (i) => i));
                }
              else
                {
                  selectedIndices.addAll(List<int>.generate(songs.length, (i) => i));
                }
                break;
      case Playlist: selectedIndices.addAll(List<int>.generate(playlists.length, (i) => i));
              break;
    }
    notifyListeners();
  }

  void toggleSelection(int index, Type newSelectionType)
  {
    if(selectedIndices.contains(index))
    {
      selectedIndices.remove(index);
    }
    else
    {
      selectedIndices.add(index);
    }
    selectionType = newSelectionType;
    notifyListeners();
  }

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

  void createPlaylist(String playlistName)
  {
    String finalName = playlistName == "" ? "Playlist " + (playlists.length + 1).toString() : playlistName;
    Playlist newPlaylist = Playlist(songs: [], name: finalName, songPaths: []);
    playlists.add(newPlaylist);
    sortPlaylists(playlists);
    savePlaylists();
    notifyListeners();
  }

  void addToPlaylist(Playlist playlist)
  {
      List<Song> newSongs = [];
      selectedIndices.forEach((element) {
        if(selectionType == Song)
          {
            newSongs.add(songs[element]);
          }
        else if(selectionType == Artist)
          {
            newSongs.addAll((artists[element]).songs);
          }
        else if(selectionType == Album)
          {
            newSongs.addAll((albums[element]).songs);
          }
      });
      playlist.addToPlaylist(newSongs);
      savePlaylists();
      clearSelections();
  }

  void deletePlaylists()
  {
    selectedIndices.forEach((element) {
      playlists.removeAt(element);
    });
    savePlaylists();
    clearSelections();
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
    playlists.clear();


    /*//If you haven't already got locations to look for music
    if(!File(appDocumentsDirectory + "/music_locations.txt").existsSync())
      {
          await getNewDirectory();
      }*/
    //If you have already got locations then load them.
    try
      {
        directoryPaths = jsonDecode(File(appDocumentsDirectory + "/music_locations.txt").readAsStringSync()).cast<String>();
      }
    catch (error)
    {
      await getNewDirectory();
    }
    var retriever = new MetadataRetriever();
    //If the album art directory doesn't exist create it
    if(!Directory(appDocumentsDirectory + "/albumart").existsSync())
    {
      Directory(appDocumentsDirectory + "/albumart").createSync();
    }
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
    //Sort the songs into artists and albums
    songs.forEach((element) {
      addToArtistsAndAlbums(element, null, null);
    });
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
    //If the playlists file exists load everything from it
    if(File(appDocumentsDirectory + "/playlists.txt").existsSync())
    {
      String playlistsFile = await File(appDocumentsDirectory + "/playlists.txt").readAsString();
      var jsonFile = jsonDecode(playlistsFile);
      playlists = Playlist.loadPlaylistFile(jsonFile, songs);
    }
    //Load your settings file
    try
    {
      String settingsFile = await File(appDocumentsDirectory + "/settings.txt").readAsString();
      var jsonFile = jsonDecode(settingsFile);
      settings = Settings.fromJson(jsonFile);
      settings.loadSongs(songs);
      if(settings.currentlyPlaying != null)
        {
          await audioPlayer.setFilePath(settings.currentlyPlaying!.filePath);
          audioPlayer.pause();
        }
    }
    catch(error){}
    //Sort the song and album lists
    sortByTrackName(songs);
    //sortByDuration(songs);
    sortByAlbumName(albums);
    sortByArtistName(artists);
    artists.forEach((element) {
      sortByAlbumDiscAndTrackNumber(element.songs);
    });
    albums.forEach((element) {
      sortByNumber(element.songs);
    });
    //Remove all the artists and albums that have 0 songs in them
    //TODO Test this part by changing the directory that is used to search songs.
    for (int i = albums.length; i > 0; i--)
      {
        if(albums[i - 1].songs.length == 0)
          {
            albums.removeAt(i - 1);
            notifyListeners();
          }
        //If you aren't removing it check if the album's metadata needs to be updated
        else
          {
            if(albums[i - 1].lastModified.isBefore(albums[i - 1].songs[0].lastModified))
            {
              Uint8List? albumArt;
              String albumYear = "Unknown Year";
              File file = File(albums[i - 1].songs[0].filePath);
              await retriever.setFile(file);
              Metadata metaData = await retriever.metadata;
              if (retriever.albumArt != null) {
                albumArt = retriever.albumArt!;
              }
              if(metaData.year != null)
              {
                albumYear = metaData.year.toString();
              }
              albums[i - 1].updateAlbum(albumYear, albumArt, albums[i - 1].songs[0].lastModified, appDocumentsDirectory);
            }
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
    //Set up the listener to detect when songs finish
    audioPlayer.playerStateStream.listen((state) {
      print(state.processingState);
      if(state.processingState == ProcessingState.completed)
        {
          if(settings.loop == LoopType.singleSong)
          {
            audioPlayer.seek(Duration());
          }
          else
            {
              playNextSong();
            }
        }
    });
    //Check for changed album metadata
    /*await Future.forEach(albums, (Album album) async {
      if(album.lastModified.isBefore(album.songs[0].lastModified))
        {
          Uint8List? albumArt;
          String albumYear = "Unknown Year";
          File file = File(album.songs[0].filePath);
          await retriever.setFile(file);
          Metadata metaData = await retriever.metadata;
          if (retriever.albumArt != null) {
            albumArt = retriever.albumArt!;
          }
          if(metaData.year != null)
          {
            albumYear = metaData.year.toString();
          }

        }
    });*/


    loading = false;
    notifyListeners();
    //Save the songs, playlists, albums, and artist lists
    String albumsJson = jsonEncode(Album.saveAlbumFile(albums, appDocumentsDirectory));
    File(appDocumentsDirectory + "/albums.txt").writeAsString(albumsJson);
    String artistsJson = jsonEncode(Artist.saveArtistFile(artists));
    File(appDocumentsDirectory + "/artists.txt").writeAsString(artistsJson);
    String songsJson = jsonEncode(Song.saveSongFile(songs));
    File(appDocumentsDirectory + "/songs.txt").writeAsString(songsJson);
    String playlistsJson = jsonEncode(Playlist.savePlaylistFile(playlists));
    File(appDocumentsDirectory + "/playlists.txt").writeAsString(playlistsJson);
    //Save your settings
    saveSettings();
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
  //Sorts a list of songs for duration
  void sortByDuration(List<Song> songList)
  {
    songList.sort((a, b) => a.duration.compareTo(b.duration));
  }
  void sortPlaylists(List<Playlist> playlistList)
  {
    playlistList.sort((a, b) => a.name.compareTo(b.name));
  }


  Uint8List? getAlbumArt(Song song)
  {
    try
    {
      return albums.firstWhere((element) => song.albumArtist == element.albumArtist && song.album == element.name).albumArt;
    }
    catch(error)
    {
      return null;
    }
  }
  //Function to clear out all the local files I am creating for this app
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
    if(File(documentStorage + "/playlists.txt").existsSync())
    {
      File(documentStorage + "/playlists.txt").delete();
    }
    if(File(documentStorage + "/settings.txt").existsSync())
    {
      File(documentStorage + "/settings.txt").delete();
    }
  }

  void addToArtistsAndAlbums(Song newSong, Uint8List? albumArt, String? albumYear)
  {
    /*if(artists.any((element) => element.name == newSong.artist))
    {
      artists.firstWhere((element) => element.name == newSong.artist).songs.add(newSong);
    }
    else
    {
      Artist newArtist = Artist(songs: [], name: newSong.artist);
      newArtist.songs.add(newSong);
      artists.add(newArtist);
    }*/
    try
    {
      artists.firstWhere((element) => element.name == newSong.artist).songs.add(newSong);
    }
    catch(error)
    {
      Artist newArtist = Artist(songs: [], name: newSong.artist);
      newArtist.songs.add(newSong);
      artists.add(newArtist);
    }
    //If the album is unknown album and you are making a new album set the album artist to various artists, if you are adding to unknown album ignore the album artist from the song and use various artists
    try
    {
      if(newSong.album == "Unknown Album")
        {
          albums.firstWhere((element) => element.name == newSong.album && element.albumArtist == "Various Artists").songs.add(newSong);
        }
      else
        {
          albums.firstWhere((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist).songs.add(newSong);
        }
    }
    catch(error)
    {
      Album newAlbum = Album(songs: [], name: newSong.album, albumArtist: newSong.album == "Unknown Album" ? "Various Artists" : newSong.albumArtist, albumArt: albumArt, year: albumYear == null ? "Unknown Year" : albumYear, lastModified: newSong.lastModified);
      newAlbum.songs.add(newSong);
      albums.add(newAlbum);
    }
    /*if(albums.any((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist))
    {
      albums.firstWhere((element) => element.name == newSong.album && element.albumArtist == newSong.albumArtist).songs.add(newSong);
    }
    else
    {
      Album newAlbum = Album(songs: [], name: newSong.album, albumArtist: newSong.albumArtist, albumArt: albumArt, year: albumYear == null ? "Unknown Year" : albumYear, lastModified: newSong.lastModified);
      newAlbum.songs.add(newSong);
      albums.add(newAlbum);
    }*/
  }
  //Function that sets the currently playing song
  void setCurrentlyPlaying(Song song, List<Song> futureSongs) async
  {
    settings.currentlyPlaying = song;
    settings.upNext.clear();
    settings.upNext.addAll(futureSongs);
    settings.originalUpNext.clear();
    settings.originalUpNext.addAll(futureSongs);
    if(settings.shuffle)
      {
        settings.upNext.shuffle();
      }
    settings.setSongPath();
    settings.playingIndex = settings.upNext.indexOf(song);
    settings.startingIndex = settings.playingIndex;
    await audioPlayer.setFilePath(song.filePath);
    audioPlayer.play();
    notifyListeners();
    saveSettings();
  }
  //Plays the next song in the playlist
  void playNextSong() async
  {
    settings.playingIndex++;
    settings.playingIndex %= settings.upNext.length;
    settings.currentlyPlaying = settings.upNext[settings.playingIndex];
    await audioPlayer.setFilePath(settings.currentlyPlaying!.filePath);
    if((settings.playingIndex == settings.startingIndex && settings.loop == LoopType.none && settings.shuffle) || (settings.playingIndex == 0 && settings.loop == LoopType.none && !settings.shuffle) || !audioPlayer.playing)
    {
      audioPlayer.pause();
    }
    else
    {
      audioPlayer.play();
    }
    notifyListeners();
    saveSettings();
  }
  //Plays the previous song in the playlist
  void playPreviousSong() async
  {
    settings.playingIndex--;
    settings.playingIndex %= settings.upNext.length;
    settings.currentlyPlaying = settings.upNext[settings.playingIndex];
    await audioPlayer.setFilePath(settings.currentlyPlaying!.filePath);
    if(audioPlayer.playing)
      {
        audioPlayer.play();
      }
    else
      {
        audioPlayer.pause();
      }
    notifyListeners();
    saveSettings();
  }
  void playButton()
  {
    audioPlayer.playing ? audioPlayer.pause() : audioPlayer.play();
    notifyListeners();
  }
  //Toggles shuffle behaviour when the shuffle button is pressed
  void toggleShuffle()
  {
    //Toggle the tracking variable
    settings.shuffle = !settings.shuffle;
    //If you are now shuffling, shuffle the upNext playlist
    if(settings.shuffle)
      {
        settings.upNext.shuffle();
        settings.setSongPath();
      }
    //If you are not shuffling set the upNext playlist to the original unshuffled one
    else
      {
        List<Song> newUpNext = [];
        newUpNext.addAll(settings.originalUpNext);
        settings.upNext = newUpNext;
        settings.setSongPath();
      }
    //Set the currently playing index to the index of the currently playing song
    if(settings.currentlyPlaying != null)
      {
        settings.playingIndex = settings.upNext.indexOf(settings.currentlyPlaying!);
        //Set the starting index to this position
        settings.startingIndex = settings.playingIndex;
      }
    notifyListeners();
    saveSettings();
  }
  
  //Plays a random song and sets shuffle to true
  playRandomSong(List<Song> futureSongs)
  {
    settings.shuffle = true;
    setCurrentlyPlaying(futureSongs[randomNumbers.nextInt(futureSongs.length)], futureSongs);
    saveSettings();
  }
  

  void toggleLoop()
  {
    switch(settings.loop)
    {
      case LoopType.singleSong:
        settings.loop = LoopType.none;
        break;
      case LoopType.loop:
        settings.loop = LoopType.singleSong;
        break;
      case LoopType.none:
        settings.loop = LoopType.loop;
        break;
    }
      notifyListeners();
      saveSettings();
  }
  void nextButton()
  {
    //audioPlayer.seekToNext();
    playNextSong();
  }

  void previousButton()
  {
    if(audioPlayer.position.inSeconds > audioPlayer.duration!.inSeconds / 20)
      {
        audioPlayer.seek(Duration());
      }
    else
      {
        playPreviousSong();
      }
  }

  void saveSettings()
  {
    File(appDocumentsDirectory + "/settings.txt").writeAsString(jsonEncode(settings.toJson()));
  }

  void savePlaylists()
  {
    String playlistsJson = jsonEncode(Playlist.savePlaylistFile(playlists));
    File(appDocumentsDirectory + "/playlists.txt").writeAsString(playlistsJson);
  }

}