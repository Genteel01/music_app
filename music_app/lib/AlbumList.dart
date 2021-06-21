import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AlbumDetails.dart';
import 'DataModel.dart';
class AlbumList extends StatefulWidget {
  const AlbumList({Key? key}) : super(key: key);

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
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
                      var album = dataModel.albums[index];
                      if(album.songs.length == 0)
                        {
                          return Container(height: 0);
                        }
                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                        child: ListTile(
                          selected: dataModel.selectedIndices.contains(index),
                          title: Text(album.name),
                          trailing: Text(album.songs.length.toString() + " tracks"),
                          subtitle: Text(album.albumArtist),
                          leading: SizedBox(width: 50, height: 50, child: album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(album.albumArt!)),
                          //leading: SizedBox(width: 50, height: 50, child: dataModel.getAlbumArt(artist.songs[0]) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs[0])!)),
                          onTap: () async => {
                            if(!dataModel.selecting)
                              {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return AlbumDetails(index: index);
                                    }))
                              }
                            else
                              {
                                if(dataModel.selectedIndices.contains(index))
                                  {
                                    dataModel.selectedAlbums.remove(album),
                                    dataModel.selectedIndices.remove(index),
                                    dataModel.setSelecting(),
                                  }
                                else
                                  {
                                    dataModel.selectedAlbums.add(album),
                                    dataModel.selectedIndices.add(index),
                                    dataModel.setSelecting(),
                                  }
                              }
                          },
                          onLongPress: () => {
                            if(dataModel.selectedIndices.contains(index))
                              {
                                dataModel.selectedAlbums.remove(album),
                                dataModel.selectedIndices.remove(index),
                                dataModel.setSelecting(),
                              }
                            else
                              {
                                dataModel.selectedAlbums.add(album),
                                dataModel.selectedIndices.add(index),
                                dataModel.setSelecting(),
                              }
                          },
                        ),
                      );
                    },
                    itemCount: dataModel.albums.length
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}