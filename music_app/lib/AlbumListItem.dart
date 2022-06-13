import 'dart:io';

import 'package:music_app/Values.dart';
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
    return Container(height: Dimens.listItemSize, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), bottom: BorderSide(width: Dimens.thinBorderSize, color: Colours.listDividerColour))),
      child: Row(
        children: [
          if (dataModel.inSelectMode) Checkbox(value: dataModel.selectedIndices.contains(dataModel.albums.indexOf(widget.album)), onChanged: (value) {
            if(widget.allowSelection)
            {
              dataModel.toggleSelection(dataModel.albums.indexOf(widget.album), Album);
            }
          }),
          Expanded(
            child: ListTile(
              selected: dataModel.selectedIndices.contains(dataModel.albums.indexOf(widget.album)),
              title: Text(widget.album.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
              trailing: Text(widget.album.songs.length == 1 ? "${widget.album.songs.length} track" : "${widget.album.songs.length} tracks"),
              subtitle: Text(widget.album.albumArtist, maxLines: 1, overflow: TextOverflow.ellipsis,),
              leading: Hero(tag: widget.album.name, child: widget.album.albumArt == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(widget.album.albumArt))),
              onTap: () {
                if(!dataModel.inSelectMode && widget.goToDetails)
                  {
                    Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => AlbumDetails(index: dataModel.albums.indexOf(widget.album)))
                      /*MaterialPageRoute(
                        builder: (context) {
                          return AlbumDetails(index: dataModel.albums.indexOf(widget.album));
                        })*/
                    ).then((value) {
                      dataModel.clearSelections();
                    });
                  }
                else if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(dataModel.albums.indexOf(widget.album), Album);
                  }
              },
              onLongPress: () {
                if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(dataModel.albums.indexOf(widget.album), Album);
                  }
              },
            ),
          ),
        ],
      ),
    );
  }
}