import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'Song.dart';

class DataModel extends ChangeNotifier {

  //added this
  bool loading = false;
  List<Song> songs = [];

  //replaced this
  DataModel()
  {
    fetch();
  }

  //added this
  Future<void> fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    songs.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    var retriever = new MetadataRetriever();
    if(directoryPath != null)
    {
      var directoryMap = Directory(directoryPath).listSync(recursive: true);
      await Future.forEach(directoryMap, (FileSystemEntity filePath) async {
        if(filePath.path.endsWith("mp3") || filePath.path.endsWith("flac"))
        {
          File file = File(filePath.path);
          await retriever.setFile(file);
          Metadata metaData = await retriever.metadata;
          File albumArt = File.fromRawPath(retriever.albumArt!);
          songs.add(Song(file: file, metaData: metaData, albumArt: albumArt));
        }
      });
    }
    loading = false;
    notifyListeners();
  }
}