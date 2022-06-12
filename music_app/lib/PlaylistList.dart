import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/PlaylistDetails.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Playlist.dart';
class PlaylistList extends StatefulWidget {
  const PlaylistList({Key? key}) : super(key: key);

  @override
  _PlaylistListState createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildScaffold
    );
  }
  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[if(dataModel.loading) CircularProgressIndicator() else
            PlaylistListBuilder(addingToPlaylist: false,)
          ],
        ),
      ),
    );
  }
}

class PlaylistListBuilder extends StatelessWidget {
  final bool addingToPlaylist;
  const PlaylistListBuilder({
    Key? key, required this.addingToPlaylist
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildList
    );
  }
  Widget buildList(BuildContext context, DataModel dataModel, _){
    ScrollController myScrollController = ScrollController();
    return Expanded(
      child: Container(decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour),)),
        child: DraggableScrollbar.arrows(
          backgroundColor: Theme.of(context).primaryColor,
          controller: myScrollController,
          child: ListView.builder(
            controller: myScrollController,
              itemBuilder: (_, index) {
                //If it is the first item make the Create Playlist button
                if(index == 0)
                  {
                    final playlistNameController = TextEditingController();
                    return Container(height: Dimens.listItemSize, decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), bottom: BorderSide(width: Dimens.thinBorderSize, color: Colours.listDividerColour))),
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.add_box),
                          title: Text("Create new Playlist"),
                          subtitle: Text(dataModel.playlists.length == 1 ? "${dataModel.playlists.length} Playlist" : "${dataModel.playlists.length} Playlists"),
                          onTap: () {
                            showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: const Text("New Playlist"),
                                      content: TextField(controller: playlistNameController, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: "Playlist ${(dataModel.playlists.length + 1)}"),),
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
                                    dataModel.createPlaylist(playlistNameController.text);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Playlist Created"),
                                    ));
                                  }
                            });
                          },
                        ),
                      ),
                    );
                  }
                var playlist = dataModel.playlists[index - 1];

                return Container(decoration: BoxDecoration(
                    border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), bottom: BorderSide(width: Dimens.thinBorderSize, color: Colours.listDividerColour))),
                  child: Center(
                    child: ListTile(
                      selected: !addingToPlaylist && dataModel.selectedIndices.contains(dataModel.playlists.indexOf(playlist)),
                      title: Text(playlist.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
                      trailing: Text(playlist.songs.length == 1 ? "${playlist.songs.length} Track" : "${playlist.songs.length} Tracks"),
                      leading: dataModel.inSelectMode ? Checkbox(value: dataModel.selectedIndices.contains(dataModel.playlists.indexOf(playlist)), onChanged: (value) {
                        if(!addingToPlaylist)
                        {
                          dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
                        }
                      }) : null,
                      onTap: () {
                        if(addingToPlaylist)
                          {
                            dataModel.addToPlaylist(playlist);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Songs Added to Playlist"),
                            ));
                            Navigator.pop(context);
                          }
                        else
                          {
                            if(!dataModel.inSelectMode)
                              {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return PlaylistDetails(index: index - 1);
                                  })).then((value) {
                                  dataModel.clearSelections();
                                });
                              }
                            else
                              {
                                dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
                              }
                          }
                      },
                      onLongPress: () {
                        if(!addingToPlaylist)
                          {
                            dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
                          }
                      },
                    ),
                  ),
                );
              },
              itemCount: dataModel.playlists.length + 1,
          ),
        ),
      ),
    );
  }
}