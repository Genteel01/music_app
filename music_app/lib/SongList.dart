import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
class SongList extends StatefulWidget {
  const SongList({Key? key}) : super(key: key);

  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
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
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (_, index) {
                      var song = dataModel.songs[index];

                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                        child: ListTile(
                          title: Text(song.name),
                          subtitle: Text(song.artist),
                          trailing: Text(song.durationString()),
                          //leading: Image.file(song.albumArt),
                          leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(song)!)),
                          onTap: () => {
                            dataModel.setCurrentlyPlaying(song),
                          },
                        ),
                      );
                    },
                    itemCount: dataModel.songs.length
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}