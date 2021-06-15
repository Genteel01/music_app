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

  //TODO to check for changes on startup store the old file map and check if the new one is different. If it is, get all the songs at the different spots, then sort all the lists again
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
      //TODO wrap this in a try catch block to deal with the cases where it tries to map inaccessible system files
      var directoryMap = Directory(directoryPath).listSync(recursive: true);
      await Future.forEach(directoryMap, (FileSystemEntity filePath) async {
        if(filePath.path.endsWith("mp3") || filePath.path.endsWith("flac") || filePath.path.endsWith("m4a"))
        {
          File file = File(filePath.path);
          await retriever.setFile(file);
          Metadata metaData = await retriever.metadata;
          File? albumArt;
          if(retriever.albumArt != null)
            {
              albumArt = File.fromRawPath(retriever.albumArt!);
            }
          songs.add(Song(metaData, file, albumArt));
        }
      });
    }
    loading = false;
    notifyListeners();
  }
}