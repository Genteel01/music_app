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
            Expanded(
              child: Container(decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                child: ListView.builder(
                  //TODO Experiment with these two variables (On all lists)
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (_, index) {
                      var playlist = dataModel.playlists[index];

                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                        child: Center(
                          child: ListTile(
                            selected: dataModel.selectedIndices.contains(index),
                            title: Text(playlist.name),
                            trailing: Text(playlist.songs.length.toString() + " Tracks"),
                            onTap: () async => {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return PlaylistDetails(index: index);
                                  }))
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: dataModel.playlists.length
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}