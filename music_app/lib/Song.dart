import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class Song {
  File file;
  Metadata metaData;
  File albumArt;

  Song({required this.file, required this.metaData, required this.albumArt});
}