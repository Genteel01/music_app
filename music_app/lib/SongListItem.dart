import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Song.dart';

class SongListItem extends StatefulWidget {
  const SongListItem({Key? key, required this.song, required this.allowSelection, required this.futureSongs, required this.index, required this.playSongs}) : super(key: key);
  final Song song;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  //Which songs will be added to up next when you play a song
  final List<Song> futureSongs;
  //Need this because there might be several copies of the same song in a playlist
  final int index;
  //When adding to a playlist from the playlist details screen we don't want to be able to play songs
  final bool playSongs;

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
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: ListTile(
        selected: dataModel.selectedIndices.contains(widget.index) || (dataModel.selectedIndices.length == 0 && dataModel.settings.upNext.length == widget.futureSongs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song),
        title: Text(widget.song.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
        subtitle: Text(widget.song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,),
        trailing: dataModel.settings.upNext.length == widget.futureSongs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song ? Row(mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.song.durationString()),
            Icon(Icons.play_arrow)
          ],
        ) : Text(widget.song.durationString()),
        leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(widget.song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(widget.song)))),
        onTap: () => {
          if(dataModel.selectedIndices.length == 0 && widget.playSongs)
            {
              dataModel.setCurrentlyPlaying(widget.index, widget.futureSongs),
            }
          else if(widget.allowSelection)
            {
              dataModel.toggleSelection(widget.index, Song)
            }
        },
        onLongPress: () => {
          if(widget.allowSelection)
            {
              dataModel.toggleSelection(widget.index, Song)
            }
        },
      ),
    );
  }
}