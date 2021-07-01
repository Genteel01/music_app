import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/PlaylistDetails.dart';
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
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
        child: DraggableScrollbar.arrows(
          backgroundColor: Theme.of(context).primaryColor,
          controller: myScrollController,
          child: ListView.builder(
            controller: myScrollController,
              itemBuilder: (_, index) {
                if(index == 0)
                  {
                    final playlistNameController = TextEditingController();
                    return Container(height: 70, decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.add_box),
                          title: Text("Create new Playlist"),
                          subtitle: Text(dataModel.playlists.length == 1 ? dataModel.playlists.length.toString() + " Playlist" : dataModel.playlists.length.toString() + " Playlists"),
                          onTap: () => {
                            showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: const Text("New Playlist"),
                                      content: TextField(controller: playlistNameController, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: "Playlist " + (dataModel.playlists.length + 1).toString()),),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Create'),
                                        ),
                                      ],
                                    )
                            ).then((value) =>
                            {
                                if(value != null && value)
                                  {
                                    dataModel.createPlaylist(playlistNameController.text)
                                  }
                            }),
                          },
                        ),
                      ),
                    );
                  }
                var playlist = dataModel.playlists[index - 1];

                return Container(height: 70, decoration: BoxDecoration(
                    border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                  child: Center(
                    child: ListTile(
                      selected: !addingToPlaylist && dataModel.selectedIndices.contains(dataModel.playlists.indexOf(playlist)),
                      title: Text(playlist.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
                      trailing: Text(playlist.songs.length == 1 ? playlist.songs.length.toString() + " Track" : playlist.songs.length.toString() + " Tracks"),
                      onTap: () => {
                        if(addingToPlaylist)
                          {
                            dataModel.addToPlaylist(playlist),
                            Navigator.pop(context)
                          }
                        else
                          {
                            if(dataModel.selectedIndices.length == 0)
                              {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return PlaylistDetails(index: index - 1);
                                  })).then((value) {
                                  dataModel.clearSelections();
                                })
                              }
                            else
                              {
                                dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist)
                              }
                          }
                      },
                      onLongPress: () => {
                        if(!addingToPlaylist)
                          {
                            dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist)
                          }
                      },
                    ),
                  ),
                );
              },
              itemCount: dataModel.playlists.length + 1,
            itemExtent: 70,
          ),
        ),
      ),
    );
  }
}