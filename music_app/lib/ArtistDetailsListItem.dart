import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'Artist.dart';
import 'DataModel.dart';
import 'Song.dart';

class ArtistDetailsListItem extends StatefulWidget {
  const ArtistDetailsListItem({Key? key, required this.song, required this.artist, required this.index}) : super(key: key);
  final Song song;
  final Artist artist;
  //The index of the song (not the index in the list
  final int index;

  @override
  _ArtistDetailsListItemState createState() => _ArtistDetailsListItemState();
}

class _ArtistDetailsListItemState extends State<ArtistDetailsListItem> {
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
          if (dataModel.inSelectMode) Checkbox(value: dataModel.selectedIndices.contains(widget.artist.songs.indexOf(widget.song)) || (!dataModel.inSelectMode && dataModel.settings.upNext.length == widget.artist.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song),
              onChanged: (value) {
                dataModel.toggleSelection(widget.index, Song);
              }),
          Expanded(
            child: ListTile(
              selected: dataModel.selectedIndices.contains(widget.artist.songs.indexOf(widget.song)) || (!dataModel.inSelectMode && dataModel.settings.upNext.length == widget.artist.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song),
              title: Text(widget.song.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
              subtitle: Text(widget.song.album, maxLines: 1, overflow: TextOverflow.ellipsis,),
              trailing: dataModel.settings.upNext.length == widget.artist.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song ? Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.song.durationString()),
                  Icon(Icons.play_arrow)
                ],
              ) : Text(widget.song.durationString()),
              leading: dataModel.getAlbumArt(widget.song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(widget.song))),
              onTap: () {
                if(!dataModel.inSelectMode)
                  {
                    dataModel.setCurrentlyPlaying(widget.index, widget.artist.songs);
                  }
                else
                  {
                    dataModel.toggleSelection(widget.index, Song);
                  }
              },
              onLongPress: () {
                dataModel.toggleSelection(widget.index, Song);
              },
            ),
          ),
        ],
      ),
    );
  }
}