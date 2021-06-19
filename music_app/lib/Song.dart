import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class Song {
  String filePath;
  String name;
  String artist;
  String album;
  int duration;
  String albumArtist;
  int discNumber;
  int trackNumber;
  DateTime lastModified;
  //String year;

  /*Song({required this.file,
    required this.name,
    this.artist = "Unknown Artist",
    this.album = "Unknown Album",
    required this.duration,
    this.albumArtist = "Unknown Artist",
    this.discNumber = 1,
    this.trackNumber = 1,
    this.year = "Unknown Year",
    this.durationNumber = 1,
  });*/
  Song(Metadata metadata, String songFilePath, DateTime modified/*, Uint8List? songAlbumArt*/)
  :
    name = metadata.trackName == null ? songFilePath.split("/").last.split(".").first : metadata.trackName!,
    artist = metadata.trackArtistNames == null ? "Unknown Artist" : artistString(metadata.trackArtistNames!),
    album = metadata.albumName == null ? "Unknown Album" : metadata.albumName!,
    albumArtist = metadata.albumArtistName == null ? (metadata.trackArtistNames == null ? "Unknown Artist" : artistString(metadata.trackArtistNames!)) : metadata.albumArtistName!,
    discNumber = metadata.discNumber == null ? 1 : metadata.discNumber!,
    trackNumber = metadata.trackNumber == null ? 1 : metadata.trackNumber!,
    //year = metadata.year == null ? "Unknown Year" : metadata.year.toString(),
    duration = metadata.trackDuration == null ? 0 : metadata.trackDuration!,
    filePath = songFilePath,
    lastModified = modified;
    //albumArt = songAlbumArt;

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
  Song.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        artist = json['artist'],
        album = json['album'],
        duration = json['duration'],
        albumArtist = json['albumArtist'],
        discNumber = json['discNumber'],
        trackNumber = json['trackNumber'],
        filePath = json['filePath'],
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']);

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'artist': artist,
        'album' : album,
        'duration' : duration,
        'albumArtist' : albumArtist,
        'discNumber': discNumber,
        'trackNumber' : trackNumber,
        'filePath' : filePath,
        'lastModified' : lastModified.millisecondsSinceEpoch,

      };

}
