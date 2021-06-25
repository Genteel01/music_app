import 'package:flutter/material.dart';
import 'package:music_app/SongList.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'DataModel.dart';
import 'Playlist.dart';

class PlaylistDetails extends StatelessWidget {
  final int index;

  PlaylistDetails({required this.index}) : super();
  final filterController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Playlist playlist = dataModel.playlists[index];
    return Scaffold(
        appBar: AppBar(
          title: Text(playlist.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        if(index == 0)
                        {
                          return ShuffleButton(dataModel: dataModel, futureSongs: playlist.songs);
                        }
                        var song = playlist.songs[index - 1];

                        return SongListItem(song: song, allowSelection: true, futureSongs: playlist.songs);
                      },
                      itemCount: playlist.songs.length + 1
                  ),
                ),
              )
            ]
        )
    );
  }
}