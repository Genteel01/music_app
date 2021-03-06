import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'PlaylistListItem.dart';
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
          child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
            controller: myScrollController,
              itemBuilder: (_, index) {
                //If it is the first item make the Create Playlist button
                if(index == 0)
                  {
                    final playlistNameController = TextEditingController();
                    return Container(height: Dimens.listItemSize,
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.add_box, color: Colours.searchHeaderTextColour,),
                          title: Text("Create New Playlist", style: TextStyle(color: Colours.searchHeaderTextColour),),
                          subtitle: Text(dataModel.playlists.length == 1 ? "${dataModel.playlists.length} Playlist" : "${dataModel.playlists.length} Playlists", style: TextStyle(color: Colours.searchHeaderTextColour),),
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
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.action);
                                            },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if(!dataModel.playlists.any((element) => element.name == playlistNameController.text))
                                              {
                                                Navigator.pop(context, true);
                                                ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.action);
                                              }
                                            else
                                              {
                                                final snackBarMessage = SnackBar(
                                                  content: Text("Playlist names must be unique"),
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
                                              }
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

                return PlaylistListItem(addingToPlaylist: addingToPlaylist, playlist: playlist, index: index - 1);
              },
              itemCount: dataModel.playlists.length + 1,
          ),
        ),
      ),
    );
  }
}