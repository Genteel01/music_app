import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Song.dart';

class SongListItem extends StatefulWidget {
  const SongListItem({Key? key, required this.song, required this.allowSelection, required this.futureSongs, required this.index, required this.playSongs, this.heroTag = ""}) : super(key: key);
  final Song song;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  //Which songs will be added to up next when you play a song
  final List<Song> futureSongs;
  //Need this because there might be several copies of the same song in a playlist
  final int index;
  //When adding to a playlist from the playlist details screen we don't want to be able to play songs
  final bool playSongs;

  final String heroTag;

  @override
  _SongListItemState createState() => _SongListItemState();
}

class _SongListItemState extends State<SongListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Container(height: Dimens.listItemSize,
      child: Row(
        children: [
          if (dataModel.inSelectMode) Checkbox(value: dataModel.selectedIndices.contains(widget.index) || (!dataModel.inSelectMode && dataModel.settings.upNext.length == widget.futureSongs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song),
              onChanged: (value) {
                if(widget.allowSelection)
                {
                  dataModel.toggleSelection(dataModel.songs.indexOf(widget.song), Song);
                }
          }),
          Expanded(
            child: ListTile(
              selected: dataModel.selectedIndices.contains(widget.index) || (!dataModel.inSelectMode && dataModel.settings.upNext.length == widget.futureSongs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song),
              title: Text(widget.song.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
              subtitle: Text(widget.song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,),
              trailing: dataModel.settings.upNext.length == widget.futureSongs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song ? Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.song.durationString()),
                  Icon(Icons.play_arrow)
                ],
              ) : Text(widget.song.durationString()),
              leading: AspectRatio(aspectRatio: 1.0/1.0, child: widget.heroTag != "" ? Hero(tag: widget.heroTag,
                  child: dataModel.getAlbumArt(widget.song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(widget.song)))) :
              dataModel.getAlbumArt(widget.song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(widget.song)))),
              onTap: () {
                if(!dataModel.inSelectMode && widget.playSongs)
                  {
                    dataModel.setCurrentlyPlaying(widget.index, widget.futureSongs);
                  }
                else if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(widget.index, Song);
                  }
              },
              onLongPress: () {
                if(widget.allowSelection)
                  {
                    dataModel.toggleSelection(widget.index, Song);
                  }
              },
            ),
          ),
        ],
      ),
    );
  }
}