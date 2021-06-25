import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Playlist.dart';
import 'Song.dart';
class SongList extends StatefulWidget {
  const SongList({Key? key}) : super(key: key);

  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
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
                          return ShuffleButton(dataModel: dataModel, futureSongs: dataModel.songs,);
                        }
                        var song = dataModel.songs[index - 1];
                        return SongListItem(song: song, allowSelection: true, futureSongs: dataModel.songs, index: index - 1);
                      },
                      itemCount: dataModel.songs.length + 1,
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

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    Key? key, required this.dataModel, required this.futureSongs
  }) : super(key: key);
  final DataModel dataModel;
  final List<Song> futureSongs;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Align(alignment: Alignment.centerLeft,
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(onPressed: () => {dataModel.playRandomSong(futureSongs)}, icon: Icon(Icons.shuffle), label: Text(futureSongs.length == 1 ? "Shuffle " + futureSongs.length.toString() + " track" : "Shuffle " + futureSongs.length.toString() + " tracks" )),
          ],
        ),
      ),
    );
  }
}


class SongListItem extends StatefulWidget {
  const SongListItem({Key? key, required this.song, required this.allowSelection, required this.futureSongs, this.playlist, required this.index}) : super(key: key);
  final Song song;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  //Which songs will be added to upnext when you play a song
  final List<Song> futureSongs;
  //Need this for the selection graphic
  final Playlist? playlist;
  //Need this because there might be several copies of the same song in a playlist
  final int index;

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
        selected: dataModel.selectedIndices.contains(widget.index) || (dataModel.selectedIndices.length == 0 && dataModel.settings.currentlyPlaying == widget.song),
        title: Text(widget.song.name),
        subtitle: Text(widget.song.artist),
        trailing: dataModel.settings.currentlyPlaying == widget.song ? Row(mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.song.durationString()),
            Icon(Icons.play_arrow)
          ],
        ) : Text(widget.song.durationString()),
        leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(widget.song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(widget.song)!)),
        onTap: () => {
          if(dataModel.selectedIndices.length == 0)
            {
              dataModel.setCurrentlyPlaying(widget.song, widget.futureSongs),
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
