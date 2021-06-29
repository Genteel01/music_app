import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/SongList.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'DataModel.dart';
import 'Playlist.dart';
import 'Settings.dart';
//TODO do the menu (with settings, rename, delete, add to playlist and reorder options)
/*
*           PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
* */
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
    ScrollController myScrollController = ScrollController();
    void selectMenuButton(String button)
    {
      switch (button)
      {
        case "Rename":
          break;
        case "Reorder":
          break;
        case "Delete":
          break;
        case "Add to Playlist":
          break;
      }
    }
    Playlist playlist = dataModel.playlists[index];
    return Scaffold(
        appBar: dataModel.selectedIndices.length > 0 ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(playlist: playlist,),
        ) : AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(playlist.name),
              PopupMenuButton<String>(
                onSelected: selectMenuButton,
                itemBuilder: (BuildContext context) {
                  return {"Rename", "Reorder", "Delete", "Add to Playlist"}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: DraggableScrollbar.arrows(
                    backgroundColor: Theme.of(context).primaryColor,
                    controller: myScrollController,
                    child: ListView.builder(
                      controller: myScrollController,
                        itemBuilder: (_, index) {
                          if(index == 0)
                          {
                            return ShuffleButton(dataModel: dataModel, futureSongs: playlist.songs);
                          }
                          var song = playlist.songs[index - 1];

                          return SongListItem(song: song, allowSelection: true, futureSongs: playlist.songs, index: index - 1);
                        },
                        itemCount: playlist.songs.length + 1,
                      itemExtent: 70,
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}