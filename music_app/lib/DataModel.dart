import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
import 'Looping.dart';
import 'Playlist.dart';
import 'Settings.dart';
import 'Song.dart';
import 'Sorting.dart';

/*void _backgroundTaskEntrypoint() async {
  await AudioServiceBackground.run(() => AudioPlayerTask());
}*/
late AudioHandler _audioHandler;

class DataModel extends ChangeNotifier {

  bool loading = false;
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Playlist> playlists = [];

  Settings settings = Settings(upNext: [], shuffle: false, loop: LoopType.none, sort: SortType.AZ, playingIndex: 0, songPaths: [], originalSongPaths: [], originalUpNext: [], directoryPaths: []);

  String appDocumentsDirectory = "";

  //final audioPlayer = AudioPlayer();

  List<int> selectedIndices = [];
  Type selectionType = Song;
  bool inSelectMode = false;

  List<Object> searchResults = [];

  String errorMessage = "";

  bool isPlaying = false;
  bool wasPlaying = false;

  //Whether you are currently using the seekbar
  bool isSeeking = false;
  //The current playback position
  Duration currentPosition = Duration();
  //Needed for a slider workaround because onChangeStart and onChangeEnd fire twice each when you don't move the slider quickly
  bool seekbarIsPushed = false;

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
            element.albumName.toUpperCase().contains(searchText.toUpperCase()) ||
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

  void stopSelecting()
  {
    inSelectMode = false;
    clearSelections();
  }

  removeFromPlaylist(Playlist playlist)
  {
    selectedIndices.sort((a, b) => b.compareTo(a));
    selectedIndices.forEach((element) {
      playlist.songs.removeAt(element);
    });
    stopSelecting();
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
    inSelectMode = true;
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

  bool hasSelections()
  {
    return selectedIndices.length > 0;
  }
  //replaced this
  DataModel()
  {
    initialSetup();
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
    notifyListeners();
  }

  Future<void> removeDirectoryPath(String path) async
  {
    settings.directoryPaths.remove(path);
    await saveSettings();
    await deleteSongList();
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
      stopSelecting();
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
    stopSelecting();
  }

  Future<void> initialSetup() async {
    _audioHandler = await AudioService.init(
      builder: () {
        return AudioPlayerTask();
      },
      config: AudioServiceConfig(
        androidNotificationChannelId: 'au.com.genteel01.music_app.channel.audio',
        androidNotificationChannelName: 'Music playback',
      ),
    );
    await fetch();
  }
  Future<void> fetch() async
  {
    print("LOGGING BREAK________________________________________________________________");
    print("LOGGING Start: " + DateTime.now().toString());
    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on
    //if(!AudioService.connected)
      //{

        //await AudioService.connect();
      //}
    //await AudioService.start(backgroundTaskEntrypoint: _backgroundTaskEntrypoint);


    //_audioHandler.customAction("onStart");
    appDocumentsDirectory = await getAppDocumentsDirectory();
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
    try
    {
      String settingsFile = await File(appDocumentsDirectory + "/settings.txt").readAsString();
      var jsonFile = jsonDecode(settingsFile);
      settings = Settings.fromJson(jsonFile);
      settings.loadSongs(songs);
      if(settings.upNext.length > 0)
      {
        //Set the starting index in the background audio service
        await _audioHandler.customAction("setStartingIndex", {"index":settings.playingIndex});
        //Set the playlist in the background audio service
        await _audioHandler.customAction("setPlaylist", makeSongMap(settings.upNext));
        _audioHandler.pause();
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
          if(filePath.path.toLowerCase().endsWith("mp3") || filePath.path.toLowerCase().endsWith("flac") || filePath.path.toLowerCase().endsWith("m4a") || filePath.path.toLowerCase().endsWith("wma"))
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
    sortSongs(settings.sort);
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
            //Delete the album art if it exists
            try
            {
              File(albums[i - 1].albumArt).delete();
            }
            catch(e){}
            albums.removeAt(i - 1);
            notifyListeners();
          }
        //If you aren't removing it check if the album's metadata needs to be updated
        else
          {
            Album currentAlbum = albums[i - 1];
            if(currentAlbum.songs.any((song) => song.lastModified.isAfter(currentAlbum.lastModified)))
            {
              //Get the most recently modified song
              Song currentSong = currentAlbum.songs.reduce((song1, song2) => song1.lastModified.isBefore(song2.lastModified) ? song2 : song1);
              Uint8List? albumArt;
              String albumYear = "Unknown Year";
              File file = File(currentSong.filePath);
              await retriever.setFile(file);
              Metadata metaData = await retriever.metadata;
              if (retriever.albumArt != null) {
                albumArt = retriever.albumArt!;
              }
              if(metaData.year != null)
              {
                albumYear = metaData.year.toString();
              }
              currentAlbum.updateAlbum(albumYear, albumArt, currentSong.lastModified, appDocumentsDirectory);
            }
            //If there is no album art look for some
            if(currentAlbum.albumArt != "" && !File(currentAlbum.albumArt).existsSync())
              {
                for(int i = 0; i < currentAlbum.songs.length; i++)
                  {
                      Song albumSong = currentAlbum.songs[i];
                      File file = File(albumSong.filePath);
                      await retriever.setFile(file);
                      if (retriever.albumArt != null) {
                        currentAlbum.updateAlbumArt(appDocumentsDirectory, retriever.albumArt!);
                        break;
                      }
                  }
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

    addAlbumsToArtists();
    //Set up the listener to detect when songs finish
    _audioHandler.playbackState.listen((state) {
      /*if(state.processingState == AudioProcessingState.idle)
        {
          settings.upNext.clear();
          settings.originalUpNext.clear();
          settings.songPaths.clear();
          settings.originalSongPaths.clear();
          saveSettings();
        }*/
      isPlaying = state.playing;
      notifyListeners();
    });
    _audioHandler.customEvent.listen((event) {
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
    print("LOGGING End: " + DateTime.now().toString());
  }
  //Sorts songs depending on the sort setting
  void sortSongs(SortType newSort)
  {
    settings.sort = newSort;
    switch(settings.sort)
    {
      case SortType.AZ:
        sortByTrackName(songs, false);
        break;
      case SortType.ZA:
        sortByTrackName(songs, true);
        break;
      case SortType.ShortestFirst:
        sortByDuration(songs, false);
        break;
      case SortType.LongestFirst:
        sortByDuration(songs, true);
        break;
    }
    saveSettings();
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
    songList.sort((a, b) => a.albumName.compareTo(b.albumName) == 0 ? (a.discNumber.compareTo(b.discNumber) == 0 ? (a.trackNumber.compareTo(b.trackNumber)) : a.discNumber.compareTo(b.discNumber)): a.albumName.compareTo(b.albumName));
  }
  //Sorts a list of songs by the track name
  void sortByTrackName(List<Song> songList, bool descending)
  {
    if(descending)
      {
        songList.sort((a, b) => b.name.toUpperCase().compareTo(a.name.toUpperCase()));
      }
    else
      {
        songList.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
      }
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
  void sortByDuration(List<Song> songList, bool descending)
  {
    if(descending)
    {
        songList.sort((a, b) => b.duration.compareTo(a.duration));
    }
    else
    {
      songList.sort((a, b) => a.duration.compareTo(b.duration));
    }
  }
  void sortPlaylists(List<Playlist> playlistList)
  {
    playlistList.sort((a, b) => a.name.compareTo(b.name));
  }

  String getAlbumArt(Song song)
  {
    if(song.album != null)
      {
        return song.album!.albumArt;
      }
    else
      {
        return "";
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
  //Add the albums to all the artist objects
  void addAlbumsToArtists()
  {
    artists.forEach((artist) {
      artist.albums.addAll(albums.where((album) => album.albumArtist == artist.name || album.songs.any((song) => song.artist == artist.name)));
    });
  }

  //Get the path without the file name
  String getFolderPath(String songPath)
  {
    List<String> splitPath = songPath.split("/");
    String finalString = "";
    for(int i = 0; i < splitPath.length - 1; i++)
      {
        finalString += splitPath[i];
      }
    return finalString;
  }
  //Adds a song to the album and artist that it belongs to
  void addToArtistsAndAlbums(Song newSong, Uint8List? albumArt, String? albumYear)
  {
    try
    {
      artists.firstWhere((element) => element.name == newSong.artist).songs.add(newSong);
    }
    catch(error)
    {
      Artist newArtist = Artist(songs: [], name: newSong.artist, albums: []);
      newArtist.songs.add(newSong);
      artists.add(newArtist);
    }
    //If the album is unknown album and you are making a new album set the album artist to various artists, if you are adding to unknown album ignore the album artist from the song and use various artists
      Album? songAlbum;
      if(newSong.albumName == "Unknown Album")
        {
          if(albums.any((element) => element.name == newSong.albumName && element.albumArtist == "Various Artists"))
            {
              songAlbum = albums.firstWhere((element) => element.name == newSong.albumName && element.albumArtist == "Various Artists");
            }
        }
      else
        {
          if(albums.any((element) => element.name == newSong.albumName && element.albumArtist == newSong.albumArtist))
            {
              songAlbum = albums.firstWhere((element) => element.name == newSong.albumName && element.albumArtist == newSong.albumArtist);
            }
          else if(albums.any((element) => element.name == newSong.albumName && element.songs.any((albumSong) => getFolderPath(albumSong.filePath) == getFolderPath(newSong.filePath))))
            {
              songAlbum = albums.firstWhere((element) => element.name == newSong.albumName && element.songs.any((albumSong) => getFolderPath(albumSong.filePath) == getFolderPath(newSong.filePath)));
            }
        }
      if(songAlbum == null)
        {
            String albumArtLocation = "";
            String albumArtist =  newSong.albumName == "Unknown Album" ? "Various Artists" : newSong.albumArtist;
            String albumYearString = albumYear == null ? "Unknown Year" : albumYear;
            if(albumArt != null)
              {
                File(appDocumentsDirectory + "/albumart/" + newSong.albumName.replaceAll("/", "_") + albumArtist.replaceAll("/", "_") + albumYearString.replaceAll("/", "_")).writeAsBytes(albumArt);
                albumArtLocation = appDocumentsDirectory + "/albumart/" + newSong.albumName.replaceAll("/", "_") + albumArtist.replaceAll("/", "_") + albumYearString.replaceAll("/", "_");
              }
            songAlbum = Album(songs: [], name: newSong.albumName, albumArtist: albumArtist, albumArt: albumArtLocation, year: albumYearString, lastModified: newSong.lastModified);
            albums.add(songAlbum);
      }
      songAlbum.songs.add(newSong);
      newSong.album = songAlbum;
  }

  Duration calculateDuration(List<Song> mySongs)
  {
    int currentDuration = 0;
    mySongs.forEach((song) {
      currentDuration += song.duration;
    });
    return Duration(milliseconds: currentDuration);
  }
  //Function that sets the currently playing song
  void setCurrentlyPlaying(int index, List<Song> futureSongs) async
  {
    //if(!AudioService.connected)
    //{
      //print("in the not connected");
      //await AudioService.connect();
    //}
    //Clear the upNext list
    settings.upNext.clear();
    //Add all the future songs to upNext
    settings.upNext.addAll(futureSongs);
    //clear originalUpNext
    settings.originalUpNext.clear();
    //Add all the future songs to originalUpNext
    settings.originalUpNext.addAll(settings.upNext);
    //Set playing index
    settings.playingIndex = index;
    //If shuffle is on shuffle upNext
    if(settings.shuffle)
      {
        Song firstSong = settings.upNext[index];
        settings.upNext.shuffle();
        int shiftIndex = settings.upNext.indexOf(firstSong);
        //Shift the upNext list so that the currently playing song is the first one in the list
        for(int i = 0; i < shiftIndex; i++)
        {
          Song movedSong = settings.upNext.removeAt(0);
          settings.upNext.add(movedSong);
        }
        settings.playingIndex = 0;
      }
    //Set the song paths so that upNext can be saved and loaded again when you open the app
    settings.setSongPath();
    //Set the starting index in the background audio service
    await _audioHandler.customAction("setStartingIndex", {"index":settings.playingIndex});
    //Set the playlist in the background audio service
    await _audioHandler.customAction("setPlaylist", makeSongMap(settings.upNext));
    //Play the music
    _audioHandler.play();
    notifyListeners();
    saveSettings();
  }
  //Makes the map that is used to send song data to the isolate
  Map<String, dynamic> makeSongMap(List<Song> songList)
  {
    Map<String, dynamic> songsWithMetadata = {};
    List<MediaItem> mediaItems = [];
    List<AudioSource> audioSources = [];

    songList.forEach((element) {
      audioSources.add(AudioSource.uri(Uri.file(element.filePath)));
      mediaItems.add(
        MediaItem(
          id: element.filePath,
          artist: element.artist,
          title: element.name,
          album: element.albumName,
          artUri: Uri.file(getAlbumArt(element)),
          duration: Duration(milliseconds: element.duration)
        )
      );
    });

    songsWithMetadata["mediaItems"] = mediaItems;
    songsWithMetadata["audioSources"] = audioSources;
    return songsWithMetadata;
  }
  //Changes current song to the up next song at the given index
  void setUpNextIndex(int index)
  {
    if(settings.upNext.length != 0)
      {
        settings.playingIndex = index;
        notifyListeners();
        saveSettings();
      }
  }
  //Sets the up next index based on the passed in file path (used when resuming the application)
  void setUpNextIndexFromSongPath() async
  {
    if(settings.upNext.length != 0)
    {
      //Since we are resuming I think it is possible for the app to lose some data as memory is cleared while it is in the background, so check if you need to reconnect
      //if(!AudioService.connected)
      //{
        //print("in the not connected");
        //await AudioService.connect();
      //}
      await _audioHandler.customAction("getCurrentIndex");
    }
  }
  void playButton() async
  {
    //bool isPlaying = await AudioService.customAction("isPlaying");
    isPlaying ? await _audioHandler.pause() : await _audioHandler.play();
    notifyListeners();
  }

  Future<void> startSeek() async
  {
    isSeeking = true;
  }

  Future<void> stopSeek(Duration position) async
  {
    await _audioHandler.seek(position);
    isSeeking = false;
  }

  void seek(Duration position) async
  {
    await _audioHandler.seek(position);
  }

  void setPosition(Duration newCurrentPosition)
  {
    currentPosition = newCurrentPosition;
  }
  //Toggles shuffle behaviour when the shuffle button is pressed
  void toggleShuffle() async
  {
    //Toggle the tracking variable
    settings.shuffle = !settings.shuffle;
    notifyListeners();
    //If you are currently playing some songs deal with the playlist
    if(settings.upNext.length != 0)
      {
        //If you are now shuffling, shuffle the upNext playlist
        if(settings.shuffle)
        {
          Song firstSong = settings.upNext[settings.playingIndex];
          settings.upNext.shuffle();
          int shiftIndex = settings.upNext.indexOf(firstSong);
          //Shift the upNext list so that the currently playing song is the first one in the list
          for(int i = 0; i < shiftIndex; i++)
          {
            Song movedSong = settings.upNext.removeAt(0);
            settings.upNext.add(movedSong);
          }
          settings.playingIndex = 0;
          settings.setSongPath();
        }
        //If you are not shuffling set the upNext playlist to the original un-shuffled one
        else
        {
          Song currentlyPlayingSong = settings.upNext[settings.playingIndex];
          List<Song> newUpNext = [];
          newUpNext.addAll(settings.originalUpNext);
          settings.upNext = newUpNext;
          settings.setSongPath();
          settings.playingIndex = settings.upNext.indexOf(currentlyPlayingSong);
        }
        //Set the starting index in the background audio service
        await _audioHandler.customAction("setStartingIndex", {"index":settings.playingIndex});
        //Set the playlist in the background audio service
        await _audioHandler.customAction("updatePlaylist", makeSongMap(settings.upNext));
      }
    notifyListeners();
    saveSettings();
  }
  
  //Plays a random song and sets shuffle to true
  playRandomSong(List<Song> futureSongs)
  {
    settings.shuffle = true;
    if(futureSongs.length > 0)
      {
        setCurrentlyPlaying(randomNumbers.nextInt(futureSongs.length), futureSongs);
      }
    saveSettings();
  }
  

  void toggleLoop()
  {
    switch(settings.loop)
    {
      case LoopType.singleSong:
        settings.loop = LoopType.none;
        _audioHandler.customAction("setLoopMode", {"loopMode":"none"});
        break;
      case LoopType.loop:
        settings.loop = LoopType.singleSong;
        _audioHandler.customAction("setLoopMode", {"loopMode":"singleSong"});
        break;
      case LoopType.none:
        settings.loop = LoopType.loop;
        _audioHandler.customAction("setLoopMode", {"loopMode":"loop"});
        break;
    }
      notifyListeners();
      saveSettings();
  }
  void nextButton()
  {
    //audioPlayer.seekToNext();
    _audioHandler.skipToNext();
    //playNextSong();
    notifyListeners();
  }

  void previousButton() async
  {
    //Duration position = await AudioService.customAction("getPosition");
    //Duration duration = await AudioService.customAction("getDuration");
    _audioHandler.skipToPrevious();
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