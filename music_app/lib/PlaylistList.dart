import 'package:flutter/material.dart';
import 'package:music_app/PlaylistDetails.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
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
    return Expanded(
      child: Container(decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
        child: ListView.builder(
          //TODO Experiment with these two variables (On all lists)
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
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
                    selected: !addingToPlaylist && dataModel.selectedIndices.contains(index),
                    title: Text(playlist.name),
                    trailing: Text(playlist.songs.length.toString() + " Tracks"),
                    onTap: () => {
                      if(addingToPlaylist)
                        {
                          dataModel.addToPlaylist(playlist),
                          Navigator.pop(context)
                        }
                      else
                        {
                          if(!dataModel.selecting)
                            {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return PlaylistDetails(index: index - 1);
                                }))
                            }
                          else
                            {
                              if(dataModel.selectedIndices.contains(index))
                                {
                                  dataModel.selectedPlaylists.remove(playlist),
                                  dataModel.selectedIndices.remove(index),
                                  dataModel.setSelecting(),
                                }
                              else
                                {
                                  dataModel.selectedPlaylists.add(playlist),
                                  dataModel.selectedIndices.add(index),
                                  dataModel.setSelecting(),
                                }
                            }
                        }
                    },
                    onLongPress: () => {
                      if(!addingToPlaylist)
                        {
                          if(dataModel.selectedPlaylists.contains(playlist))
                            {
                              dataModel.selectedPlaylists.remove(playlist),
                              dataModel.selectedIndices.remove(index),
                              dataModel.setSelecting(),
                            }
                          else
                            {
                              dataModel.selectedPlaylists.add(playlist),
                              dataModel.selectedIndices.add(index),
                              dataModel.setSelecting(),
                            }
                        }
                    },
                  ),
                ),
              );
            },
            itemCount: dataModel.playlists.length + 1
        ),
      ),
    );
  }
}