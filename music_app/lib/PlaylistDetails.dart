import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ListHeader.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';


import 'AddToPlaylistScreen.dart';
import 'AlbumArtView.dart';
import 'AppBarTitle.dart';
import 'CurrentlyPlayingBar.dart';
import 'DataModel.dart';
import 'Playlist.dart';
import 'ShuffleButton.dart';
import 'SongListItem.dart';

class PlaylistDetails extends StatefulWidget {
  final int index;

  PlaylistDetails({required this.index}) : super();

  @override
  _PlaylistDetailsState createState() => _PlaylistDetailsState();
}

class _PlaylistDetailsState extends State<PlaylistDetails> {
  final filterController = TextEditingController();
  bool? reordering;
  @override
  void initState() {
    super.initState();
    reordering = false;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Widget buildScaffold(BuildContext context, DataModel dataModel, _) {
    Playlist playlist = dataModel.playlists[widget.index];
    ScrollController myScrollController = ScrollController();
    void selectMenuButton(String button)
    {
      switch (button)
      {
        case "Rename":
          final playlistNameController = TextEditingController();
          playlistNameController.text = playlist.name;
          showDialog<bool>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text("New Playlist"),
                    content: TextField(controller: playlistNameController, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: playlist.name),),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  )
          ).then((value)
          {
            if(value != null && value)
              {
                dataModel.renamePlaylist(playlist, playlistNameController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Playlist Renamed"),
                ));
              }
          });
          break;
        case "Reorder":
          setState(() {
            reordering = true;
          });
          break;
        case "Delete":
          dataModel.removePlaylist(playlist);
          Navigator.pop(context);
          final snackBarMessage = SnackBar(
            content: Text("Playlist Deleted"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
          break;
        case "Add to Playlist":
          Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddToPlaylist();
              })).then((value) {
            if(value != null && value)
            {
              dataModel.addToPlaylist(playlist);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Songs Added to Playlist"),
              ));
            }
            dataModel.clearSelections();
          });
          break;
      }
    }
    return WillPopScope(
      onWillPop: () async {
        if(dataModel.inSelectMode)
        {
          dataModel.stopSelecting();
          return false;
        }
        return true;
      },
      child: Scaffold(
          appBar: dataModel.inSelectMode ? AppBar(automaticallyImplyLeading: false,
            title: SelectingAppBarTitle(playlist: playlist,),
          ) : AppBar(automaticallyImplyLeading: !reordering!,
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(playlist.name),
                reordering! ? ElevatedButton(onPressed: () {
                  setState(() {
                    reordering = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Playlist Reordered"),
                  ));
                }, child: Text("End")) :
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
                playlist.songs.length == 0 ? ListHeader(text: "This playlist is empty!") :
                  Expanded(
                  child: reordering! ? ReorderableListView.builder(
                      itemBuilder: (_, index) {
                        var song = playlist.songs[index];

                        return Container(key: Key(index.toString()),
                          child: Column(
                            children: [
                              Container(height: Dimens.listItemSize,
                                child: ListTile(
                                  title: Text(song.name),
                                  subtitle: Text(song.artist),
                                  trailing: Icon(Icons.menu),
                                  leading: dataModel.getAlbumArt(song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(song))),
                                ),
                              ),
                              if(index != playlist.songs.length - 1) Divider()
                            ],
                          ),
                        );
                      },
                      itemCount: playlist.songs.length,
                    onReorder: (int oldIndex, int newIndex) {
                      dataModel.reorderPlaylist(oldIndex, newIndex, playlist);
                    },
                  )
                  : Container(decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour),)),
                    child: DraggableScrollbar.arrows(
                      backgroundColor: Theme.of(context).primaryColor,
                      controller: myScrollController,
                      child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                        controller: myScrollController,
                          itemBuilder: (_, index) {
                            if(index == 0)
                            {
                              return Column(
                                children: [
                                  InkWell(child: Hero(tag: playlist.name, child: !playlist.songs.any((element) => dataModel.getAlbumArt(element) != "") ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(playlist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != ""))))),
                                   onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AlbumArtView(image: dataModel.getAlbumArt(playlist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != "")), tagName: playlist.name,);
                                        }));
                                  },
                                  ),
                                  ShuffleButton(dataModel: dataModel, futureSongs: playlist.songs),
                                ],
                              );
                            }
                            var song = playlist.songs[index - 1];

                            return SongListItem(song: song, allowSelection: true, futureSongs: playlist.songs, index: index - 1, playSongs: true,);
                          },
                          itemCount: playlist.songs.length + 1,
                      ),
                    ),
                  ),
                )
              ]
          )
      ),
    );
  }
}