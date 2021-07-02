import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';



import 'Album.dart';
import 'Artist.dart';
import 'BackgroundAudio.dart';
import 'Playlist.dart';
import 'Settings.dart';
import 'Song.dart';
import 'main.dart' as main;


enum LoopType {
  none,
  loop,
  singleSong,
}
void _backgroundTaskEntrypoint() async {
  print("in the top level function");
  await AudioServiceBackground.run(() => AudioPlayerTask());
  print("after the thing in the top level function");
}
class DataModel extends ChangeNotifier {

  bool loading = false;
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Playlist> playlists = [];

  Settings settings = Settings(upNext: [], shuffle: false, loop: LoopType.none, playingIndex: 0, startingIndex: 0, songPaths: [], originalSongPaths: [], originalUpNext: [], directoryPaths: []);

  String appDocumentsDirectory = "";

  //final audioPlayer = AudioPlayer();

  List<int> selectedIndices = [];
  Type selectionType = Song;

  List<Object> searchResults = [];

  String errorMessage = "";

  bool isPlaying = false;

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
    //Have the user pick a new location to look for music
    String? newDirectoryPath = await FilePicker.platform.getDirectoryPath();
    if(newDirectoryPath != null && !settings.directoryPaths.contains(newDirectoryPath))
    {
      settings.directoryPaths.add(newDirectoryPath);
    }
    await saveSettings();
    await fetch();
    notifyListeners();
  }

  Future<void> removeDirectoryPath(String path) async
  {
    settings.directoryPaths.remove(path);
    await saveSettings();
    await deleteSongList();
    await fetch();
    notifyListeners();
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
        if (selectionType == Song)
        {
          newSongs.add(songs[element]);
        }
        else if (selectionType == Artist)
        {
          newSongs.addAll((artists[element]).songs);
        }
        else if (selectionType == Album)
        {
          newSongs.addAll((albums[element]).songs);
        }
      });
      playlist.addToPlaylist(newSongs);
      savePlaylists();
      clearSelections();
  }

  void reorderPlaylist(int oldIndex, int newIndex, Playlist playlist)
  {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Song item = playlist.songs.removeAt(oldIndex);
    playlist.songs.insert(newIndex, item);
    notifyListeners();
    savePlaylists();
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
    //if(!AudioService.connected)
      //{
        await AudioService.connect();
      //}
    await AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);
    //ReceivePort receivePort = ReceivePort();
    SendPort? blah = IsolateNameServer.lookupPortByName("audioServicePort");
    if(blah != null)
      {
        print("IT'S WORKING _______________________________________________-");
      }
    print("after calling start");
    appDocumentsDirectory = await getAppDocumentsDirectory();
    print("289");
    //clear any existing data we have gotten previously, to avoid duplicate data
    songs.clear();
    artists.clear();
    albums.clear();
    playlists.clear();
    errorMessage = "";


    var retriever = new MetadataRetriever();
    //If the album art directory doesn't exist create it
    try
    {
      Directory(appDocumentsDirectory + "/albumart").createSync();
    }
    catch(error){}
    //If the albums file exists load everything from it
    try
      {
        String albumFile = await File(appDocumentsDirectory + "/albums.txt").readAsString();
        var jsonFile = jsonDecode(albumFile);
        albums = Album.loadAlbumFile(jsonFile, appDocumentsDirectory);
      }
    catch (error){}
    //If the artists file exists load everything from it
    try
    {
      String artistsFile = await File(appDocumentsDirectory + "/artists.txt").readAsString();
      var jsonFile = jsonDecode(artistsFile);
      artists = Artist.loadArtistFile(jsonFile);
    }
    catch (error){}
    //If the songs file exists load everything from it
    try
    {
      String songsFile = await File(appDocumentsDirectory + "/songs.txt").readAsString();
      var jsonFile = jsonDecode(songsFile);
      songs = await Song.loadSongFile(jsonFile);
    }
    catch (error){}
    //Load your settings file
    print("330");
    try
    {
      String settingsFile = await File(appDocumentsDirectory + "/settings.txt").readAsString();
      var jsonFile = jsonDecode(settingsFile);
      settings = Settings.fromJson(jsonFile);
      settings.loadSongs(songs);
      if(settings.currentlyPlaying != null)
      {
        print("339");
        await AudioService.customAction("setFilePath", settings.currentlyPlaying!.filePath);
        print("341");
        AudioService.pause();
      }
    }
    catch(error){}
    //Sort the songs into artists and albums
    songs.forEach((element) {
      addToArtistsAndAlbums(element, null, null);
    });
    //Check for new songs within the directories you are looking at
    await Future.forEach(settings.directoryPaths, (String directoryPath) async {
      try
      {
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
      }
      catch(error)
      {
        errorMessage = errorMessage + "The directory \"" + directoryPath + "\" contains inaccessible system files, and could not be mapped\n";
      }
    });
    //If the playlists file exists load everything from it
    try
    {
      String playlistsFile = await File(appDocumentsDirectory + "/playlists.txt").readAsString();
      var jsonFile = jsonDecode(playlistsFile);
      playlists = Playlist.loadPlaylistFile(jsonFile, songs);
    }
    catch (error){}
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
    /*Stream<PlayerState> playerStateStream = await AudioService.customAction("getPlayStreamState");
    playerStateStream.listen((state) {
      if(state.processingState == ProcessingState.completed)
      {
        if(settings.loop == LoopType.singleSong)
        {
          AudioService.seekTo(Duration());
        }
        else
        {
          playNextSong();
        }
      }
    });*/
    AudioService.playbackStateStream.listen((state) {
      print("Processing State: " + state.processingState.toString());
      /*if(state.processingState == AudioProcessingState.completed)
      {
        if(settings.loop != LoopType.singleSong)
        {
          playNextSong();
        }
      }
      if(state.processingState == AudioProcessingState.skippingToNext)
        {
          playNextSong();
        }
      if(state.processingState == AudioProcessingState.skippingToPrevious)
        {
          if(settings.loop != LoopType.singleSong && !(settings.loop == LoopType.none && settings.playingIndex == 0))
            {
              playPreviousSong();
            }
        }*/
      if(state.processingState == AudioProcessingState.stopped)
        {
          settings.currentlyPlaying = null;
          settings.upNext.clear();
          settings.originalUpNext.clear();
          settings.songPaths.clear();
          settings.originalSongPaths.clear();
          saveSettings();
        }
      isPlaying = state.playing;
      notifyListeners();
    });
    AudioService.customEventStream.listen((event) {
      if(event.runtimeType == int)
        {
          setUpNextIndex(event);
        }
    });

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
    try
    {
      File(documentStorage + "/albums.txt").delete();
    }
    catch(error){}
    //If the artists directory exists load everything from it, else create it
    try
    {
      File(documentStorage + "/artists.txt").delete();
    }
    catch(error){}
    //If the songs directory doesn't exist create it
    try
    {
      File(documentStorage + "/songs.txt").delete();
    }
    catch(error){}
    try
    {
      Directory(documentStorage + "/songs").delete(recursive: true);
    }
    catch(error){}
    try
      {
        Directory(documentStorage + "/albums").delete(recursive: true);
      }
    catch(error){}
    try
      {
        Directory(documentStorage + "/artists").delete(recursive: true);
      }
    catch(error){}
    try
    {
      Directory(documentStorage + "/albumart").delete(recursive: true);
    }
    catch(error){}
    try
    {
      File(documentStorage + "/playlists.txt").delete();
    }
    catch(error){}
    try
    {
      File(documentStorage + "/settings.txt").delete();
    }
    catch(error){}
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
    //Set the currently playing song for the ui
    settings.currentlyPlaying = song;
    //Clear the upNext list
    settings.upNext.clear();
    //Add all the future songs to upNext
    settings.upNext.addAll(futureSongs);
    //clear originalUpNext
    settings.originalUpNext.clear();
    //Add all the future songs to originalUpNext
    settings.originalUpNext.addAll(settings.upNext);
    //If shuffle is on shuffle upNext
    if(settings.shuffle)
      {
        settings.upNext.shuffle();
      }
    //TODO shift the upNext list so that the currently playing song is the first one in the list
    //TODO shift the originalUpNext list so that the currently playing song is the first one in the list
    //Set the song paths so that upNext can be saved and loaded again when you open the app
    settings.setSongPath();
    //TODO after I am done with the shifting of playlists playingIndex and startingIndex should both be completely removable
    //Set playing index
    settings.playingIndex = settings.upNext.indexOf(song);
    //Set the starting index
    settings.startingIndex = settings.playingIndex;
    //Create the map that will be passed into the background audio service with the needed song details
    List<Map<String, dynamic>> songsWithMetadata = [];
    settings.upNext.forEach((element) { 
      Album album = element.album == "Unknown Album" ? albums.firstWhere((albumElement) => albumElement.name == element.album && albumElement.albumArtist == "Various Artists") :
      albums.firstWhere((albumElement) => albumElement.name == element.album && albumElement.albumArtist == element.albumArtist);
      Map<String, dynamic> song = {"path" : element.filePath, "name" : element.name, "artist" : element.artist, "albumart" : getAlbumArt(element) == null ? "" : appDocumentsDirectory + "/albumart/" + album.name.replaceAll("/", "_") + album.albumArtist.replaceAll("/", "_") + album.year.replaceAll("/", "_")};
      songsWithMetadata.add(song);
    });
    //Set the starting index in the background audio service
    await AudioService.customAction("setStartingIndex", settings.startingIndex);
    //Set the playlist in the packground audio service
    await AudioService.customAction("setPlaylist", songsWithMetadata);
    //Play the music
    AudioService.play();
    notifyListeners();
    saveSettings();
  }
  //Changes current song to the upnext song at the given index
  void setUpNextIndex(int index)
  {
    settings.playingIndex = index;
    settings.currentlyPlaying = settings.upNext[index];
    notifyListeners();
    saveSettings();
  }
  //Plays the next song in the playlist
  void playNextSong() async
  {
    settings.playingIndex++;
    settings.playingIndex %= settings.upNext.length;
    settings.currentlyPlaying = settings.upNext[settings.playingIndex];
    //await AudioService.customAction("setFilePath", settings.currentlyPlaying!.filePath);
    if((settings.playingIndex == settings.startingIndex && settings.loop == LoopType.none && settings.shuffle) || (settings.playingIndex == 0 && settings.loop == LoopType.none && !settings.shuffle) || !isPlaying)
    {
      AudioService.pause();
    }
    else
    {
      AudioService.play();
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
    //await AudioService.customAction("setFilePath", settings.currentlyPlaying!.filePath);
    //bool isPlaying = await AudioService.customAction("isPlaying");
    if(isPlaying)
      {
        AudioService.play();
      }
    else
      {
        AudioService.pause();
      }
    notifyListeners();
    saveSettings();
  }
  void playButton() async
  {
    //bool isPlaying = await AudioService.customAction("isPlaying");
    isPlaying ? await AudioService.pause() : await AudioService.play();
    notifyListeners();
  }
  //Toggles shuffle behaviour when the shuffle button is pressed
  //TODO this is broken as hell
  void toggleShuffle()
  {
    //Toggle the tracking variable
    settings.shuffle = !settings.shuffle;
    //If you are now shuffling, shuffle the upNext playlist
    /*if(settings.shuffle)//Happens in the setCurrentlyPlaying() now
      {
        settings.upNext.shuffle();
        settings.setSongPath();
      }
    //If you are not shuffling set the upNext playlist to the original unshuffled one
    else*/if(!settings.shuffle)
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
    setCurrentlyPlaying(settings.upNext[settings.playingIndex], settings.upNext);
    notifyListeners();
    saveSettings();
  }
  
  //Plays a random song and sets shuffle to true
  playRandomSong(List<Song> futureSongs)
  {
    settings.shuffle = true;
    if(futureSongs.length > 0)
      {
        setCurrentlyPlaying(futureSongs[randomNumbers.nextInt(futureSongs.length)], futureSongs);
      }
    saveSettings();
  }
  

  void toggleLoop()
  {
    switch(settings.loop)
    {
      case LoopType.singleSong:
        settings.loop = LoopType.none;
        AudioService.customAction("setLoopMode", "none");
        break;
      case LoopType.loop:
        settings.loop = LoopType.singleSong;
        AudioService.customAction("setLoopMode", "singleSong");
        break;
      case LoopType.none:
        settings.loop = LoopType.loop;
        AudioService.customAction("setLoopMode", "loop");
        break;
    }
      notifyListeners();
      saveSettings();
  }
  void nextButton()
  {
    //audioPlayer.seekToNext();
    AudioService.skipToNext();
    //playNextSong();
    notifyListeners();
  }

  void previousButton() async
  {
    //Duration position = await AudioService.customAction("getPosition");
    //Duration duration = await AudioService.customAction("getDuration");
    AudioService.skipToPrevious();
    /*if(AudioService.playbackState.position.inSeconds > Duration(milliseconds: settings.currentlyPlaying!.duration).inSeconds / 20)
      {
        //await AudioService.seekTo(Duration());
      }
    else
      {
        playPreviousSong();
      }*/
    notifyListeners();
  }

  Future<void> saveSettings() async
  {
    await File(appDocumentsDirectory + "/settings.txt").writeAsString(jsonEncode(settings.toJson()));
  }

  void savePlaylists()
  {
    String playlistsJson = jsonEncode(Playlist.savePlaylistFile(playlists));
    File(appDocumentsDirectory + "/playlists.txt").writeAsString(playlistsJson);
  }

  Future<void> deleteSongList() async
  {
    try
    {
      await File(appDocumentsDirectory + "/songs.txt").delete();
    }
    catch(error){}
  }

  void renamePlaylist(Playlist playlist, String newName)
  {
    if(newName != "")
      {
        playlist.name = newName;
        notifyListeners();
        savePlaylists();
      }
  }
  void removePlaylist(Playlist playlist)
  {
    playlists.remove(playlist);
    notifyListeners();
    savePlaylists();
  }
}