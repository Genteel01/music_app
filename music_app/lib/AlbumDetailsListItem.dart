import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'DataModel.dart';
import 'Song.dart';

class AlbumDetailsListItem extends StatefulWidget {
  const AlbumDetailsListItem({Key? key, required this.song, required this.album, required this.index}) : super(key: key);
  final Song song;
  final Album album;
  //The index of the song (not the index in the list
  final int index;

  @override
  _AlbumDetailsListItemState createState() => _AlbumDetailsListItemState();
}

class _AlbumDetailsListItemState extends State<AlbumDetailsListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Container(height: Dimens.listItemSize, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), bottom: BorderSide(width: Dimens.thinBorderSize, color: Colours.listDividerColour))),
      child: ListTile(
        selected: dataModel.selectedIndices.contains(widget.album.songs.indexOf(widget.song)) || (!dataModel.isSelecting() && dataModel.settings.upNext.length == widget.album.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song) ,
        title: Text(widget.song.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
        subtitle: Text(widget.song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,),
        trailing: dataModel.settings.upNext.length == widget.album.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song ? Row(mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.song.durationString()),
            Icon(Icons.play_arrow)
          ],
        ) : Text(widget.song.durationString()),
        leading: Text(widget.song.trackNumber.toString()),
        onTap: () => {
          if(!dataModel.isSelecting())
            {
              dataModel.setCurrentlyPlaying(widget.index, widget.album.songs),
            }
          else
            {
              dataModel.toggleSelection(widget.index, Song)
            }
        },
        onLongPress: () => {
          dataModel.toggleSelection(widget.index, Song)
        },
      ),
    );
  }
}