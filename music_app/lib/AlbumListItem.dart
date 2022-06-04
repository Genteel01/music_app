import 'dart:io';

import 'package:provider/provider.dart';

import 'Album.dart';
import 'package:flutter/material.dart';

import 'AlbumDetails.dart';
import 'DataModel.dart';

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
        title: Text(widget.album.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
        trailing: Text(widget.album.songs.length == 1 ? widget.album.songs.length.toString() + " track" : widget.album.songs.length.toString() + " tracks"),
        subtitle: Text(widget.album.albumArtist, maxLines: 1, overflow: TextOverflow.ellipsis,),
        leading: SizedBox(width: 50, height: 50, child: widget.album.albumArt == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(widget.album.albumArt))),
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