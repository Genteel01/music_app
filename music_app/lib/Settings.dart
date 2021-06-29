
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Song.dart';


class Settings{
  List<Song> upNext;
  List<Song> originalUpNext;
  Song? currentlyPlaying;
  bool shuffle;
  LoopType loop;
  int playingIndex;
  int startingIndex;
  List<String> songPaths;
  List<String> originalSongPaths;
  List<String> directoryPaths;

  Settings({required this.upNext, this.currentlyPlaying, required this.shuffle, required this.loop, required this.playingIndex, required this.startingIndex, required this.songPaths, required this.originalUpNext, required this.originalSongPaths, required this.directoryPaths});

  Map<String, dynamic> toJson() =>
      {
        'shuffle': shuffle,
        'loop' : EnumToString.convertToString(loop),
        'playingIndex': playingIndex,
        'startingIndex': startingIndex,
        'songPaths': songPaths,
        'originalSongPaths': originalSongPaths,
        'directoryPaths' : directoryPaths
      };

  Settings.fromJson(Map<String, dynamic> json)
      :
        shuffle = json['shuffle'],
        loop = EnumToString.fromString(LoopType.values, json['loop'])!,
        playingIndex = json['playingIndex'],
        startingIndex = json['startingIndex'],
        songPaths = json['songPaths'].cast<String>(),
        originalSongPaths = json['originalSongPaths'].cast<String>(),
        upNext = [],
        originalUpNext = [],
        directoryPaths = json['directoryPaths'].cast<String>();

  loadSongs(List<Song> allSongs)
  {
    songPaths.forEach((element) {
      try {
        upNext.add(allSongs.firstWhere((song) => song.filePath == element));
      }
      catch (error) {

      }
    });
    originalSongPaths.forEach((element) {
      try
      {
        originalUpNext.add(allSongs.firstWhere((song) => song.filePath ==element));
      }
      catch(error)
      {

      }
    });
    if(upNext.length > 0)
      {
        currentlyPlaying = upNext[playingIndex];
      }
  }
  setSongPath()
  {
    songPaths.clear();
    originalSongPaths.clear();
    upNext.forEach((element) {
      songPaths.add(element.filePath);
    });
    originalUpNext.forEach((element) {
      originalSongPaths.add(element.filePath);
    });
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: dataModel.loading ? Center(child: CircularProgressIndicator()) : Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                    child: ListView(
                      children: [
                        if(dataModel.errorMessage != "") Padding(padding: const EdgeInsets.all(8.0), child: Text(dataModel.errorMessage),),
                        DirectoriesMenuListItem(),
                      ],
                    )
                ),
              )
            ]
        )
    );
  }
}

class DirectoriesMenuListItem extends StatelessWidget {
  const DirectoriesMenuListItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text("Music Directories"),
      subtitle: Text("Choose where to look for music on this device"),
      onTap: () => {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30))),
          builder: (BuildContext context) {
            return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: Container(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: PathsList(),
                ),
              ),
            );
          },
        )
      },
    );
  }
}

class PathsList extends StatefulWidget {
  const PathsList({Key? key}) : super(key: key);

  @override
  _PathsListState createState() => _PathsListState();
}

class _PathsListState extends State<PathsList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildList
    );
  }
  Widget buildList(BuildContext context, DataModel dataModel, _){
    return ListView.builder(
      itemBuilder: (_, index) {
        if(index == 0)
        {
          return ListTile(
            leading: Icon(Icons.add),
            title: Text("Add New Location"),
            onTap: () async => {
              await dataModel.getNewDirectory(),
            },
          );
        }
        var path = dataModel.settings.directoryPaths[index - 1];

        return ListTile(
          title: Text(path),
          subtitle: Text("Hold to remove"),
          onLongPress: () async => {
            await dataModel.removeDirectoryPath(path)
          },
        );
      },
      itemCount: dataModel.settings.directoryPaths.length + 1,
    );
  }
}
