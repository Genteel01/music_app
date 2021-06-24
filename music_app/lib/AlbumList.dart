import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
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
                      if(index == 0)
                      {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(dataModel.albums.length.toString() + " albums"),
                        );
                      }
                      var album = dataModel.albums[index - 1];
                      if(album.songs.length == 0)
                        {
                          return Container(height: 0);
                        }
                      return AlbumListItem(album: album, index: index, allowSelection: true,);
                    },
                    itemCount: dataModel.albums.length + 1
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
class AlbumListItem extends StatefulWidget {
  const AlbumListItem({Key? key, required this.album, required this.index, required this.allowSelection}) : super(key: key);
  final Album album;
  final int index;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  @override
  _AlbumListItemState createState() => _AlbumListItemState();
}

class _AlbumListItemState extends State<AlbumListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: ListTile(
        selected: dataModel.selectedIndices.contains(widget.index),
        title: Text(widget.album.name),
        trailing: Text(widget.album.songs.length.toString() + " tracks"),
        subtitle: Text(widget.album.albumArtist),
        leading: SizedBox(width: 50, height: 50, child: widget.album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(widget.album.albumArt!)),
        onTap: () => {
          if(!dataModel.selecting)
            {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return AlbumDetails(index: dataModel.albums.indexOf(widget.album));
                  })).then((value) {
                dataModel.clearSelections();
              })
            }
          else if(widget.allowSelection)
            {
              if(dataModel.selectedIndices.contains(widget.index))
                {
                  dataModel.selectedAlbums.remove(widget.album),
                  dataModel.selectedIndices.remove(widget.index),
                  dataModel.setSelecting(),
                }
              else
                {
                  dataModel.selectedAlbums.add(widget.album),
                  dataModel.selectedIndices.add(widget.index),
                  dataModel.setSelecting(),
                }
            }
        },
        onLongPress: () => {
          if(widget.allowSelection)
            {
              if(dataModel.selectedIndices.contains(widget.index))
                {
                  dataModel.selectedAlbums.remove(widget.album),
                  dataModel.selectedIndices.remove(widget.index),
                  dataModel.setSelecting(),
                }
              else
                {
                  dataModel.selectedAlbums.add(widget.album),
                  dataModel.selectedIndices.add(widget.index),
                  dataModel.setSelecting(),
                }
            }
        },
      ),
    );
  }
}