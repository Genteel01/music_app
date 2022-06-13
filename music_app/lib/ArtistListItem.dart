import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Artist.dart';
import 'ArtistDetails.dart';
import 'DataModel.dart';
import 'Values.dart';

class ArtistListItem extends StatefulWidget {
  const ArtistListItem({Key? key, required this.artist, required this.allowSelection, required this.goToDetails}) : super(key: key);
  final Artist artist;
  final bool goToDetails;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  @override
  _ArtistListItemState createState() => _ArtistListItemState();
}

class _ArtistListItemState extends State<ArtistListItem> {
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
          if (dataModel.inSelectMode) Checkbox(value: dataModel.selectedIndices.contains(dataModel.artists.indexOf(widget.artist)), onChanged: (value) {
            if(widget.allowSelection)
            {
              dataModel.toggleSelection(dataModel.artists.indexOf(widget.artist), Artist);
            }
          }),
          Expanded(
            child: ListTile(
              selected: dataModel.selectedIndices.contains(dataModel.artists.indexOf(widget.artist)),
              title: Text(widget.artist.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
              subtitle: Text(widget.artist.albums.length == 1 ? "${widget.artist.albums.length} album" : "${widget.artist.albums.length} albums"),
              trailing: Text(widget.artist.songs.length == 1 ? "${widget.artist.songs.length} track" : "${widget.artist.songs.length} tracks"),
              leading: Hero(tag: widget.artist.name, child:
                !widget.artist.songs.any((element) => dataModel.getAlbumArt(element) != "") ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(widget.artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != "")))),
              ),
              onTap: () async {
                if(!dataModel.inSelectMode && widget.goToDetails)
                  {
                    Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => ArtistDetails(index: dataModel.artists.indexOf(widget.artist)))
                      /*MaterialPageRoute(
                        builder: (context) {
                          return ArtistDetails(index: dataModel.artists.indexOf(widget.artist));
                        })*/
                    ).then((value) {
                      dataModel.clearSelections();
                    });
                  }
                else if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(dataModel.artists.indexOf(widget.artist), Artist);
                  }
              },
              onLongPress: () {
                if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(dataModel.artists.indexOf(widget.artist), Artist);
                  }
              },
            ),
          ),
        ],
      ),
    );
  }
}