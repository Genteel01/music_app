import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumDetails.dart';
import 'DataModel.dart';
class AlbumList extends StatefulWidget {
  const AlbumList({Key? key, required this.goToDetails}) : super(key: key);
  final bool goToDetails;
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
    ScrollController myScrollController = ScrollController();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[if(dataModel.loading) CircularProgressIndicator() else
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
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(alignment: Alignment.centerLeft, child: Text(dataModel.albums.length == 1 ? dataModel.albums.length.toString() + " Album" : dataModel.albums.length.toString() + " Albums", style: TextStyle(fontSize: 16,),)),
                          );
                        }
                        var album = dataModel.albums[index - 1];
                        if(album.songs.length == 0)
                          {
                            return Container(height: 0);
                          }
                        return AlbumListItem(album: album, allowSelection: true, goToDetails: widget.goToDetails,);
                      },
                      itemCount: dataModel.albums.length + 1,
                    itemExtent: 70,
                  ),
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
  const AlbumListItem({Key? key, required this.album, required this.allowSelection, required this.goToDetails}) : super(key: key);
  final Album album;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  final bool goToDetails;
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
        selected: dataModel.selectedIndices.contains(dataModel.albums.indexOf(widget.album)),
        title: Text(widget.album.name),
        trailing: Text(widget.album.songs.length == 1 ? widget.album.songs.length.toString() + " track" : widget.album.songs.length.toString() + " tracks"),
        subtitle: Text(widget.album.albumArtist),
        leading: SizedBox(width: 50, height: 50, child: widget.album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(widget.album.albumArt!)),
        onTap: () => {
          if(dataModel.selectedIndices.length == 0 && widget.goToDetails)
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
              dataModel.toggleSelection(dataModel.albums.indexOf(widget.album), Album)
            }
        },
        onLongPress: () => {
          if(widget.allowSelection)
            {
              dataModel.toggleSelection(dataModel.albums.indexOf(widget.album), Album)
            }
        },
      ),
    );
  }
}