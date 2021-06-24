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

                        return Container(height: 70, decoration: BoxDecoration(
                            border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                          child: ListTile(
                            title: Text(song.name),
                            subtitle: Text(song.album),
                            trailing: Text(song.durationString()),
                            leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(song)!)),
                            onTap: () => {
                              dataModel.setCurrentlyPlaying(song, playlist.songs),
                            },
                          ),
                        );
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