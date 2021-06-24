import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[if(dataModel.loading) CircularProgressIndicator() else
            Expanded(
              child: Container(decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                child: ListView.builder(
                    //TODO Experiment with these two variables (On all lists)
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (_, index) {
                      if(index == 0)
                      {
                        return ShuffleButton(dataModel: dataModel, futureSongs: dataModel.songs,);
                      }
                      var song = dataModel.songs[index - 1];
                      return SongListItem(song: song, index: index, allowSelection: true,);
                    },
                    itemCount: dataModel.songs.length + 1
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
            ElevatedButton.icon(onPressed: () => {dataModel.playRandomSong(futureSongs)}, icon: Icon(Icons.shuffle), label: Text("Shuffle " + futureSongs.length.toString() + " tracks")),
          ],
        ),
      ),
    );
  }
}


class SongListItem extends StatefulWidget {
  const SongListItem({Key? key, required this.song, required this.index, required this.allowSelection}) : super(key: key);
  final Song song;
  final int index;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;

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
        selected: dataModel.selectedIndices.contains(widget.index) || (!dataModel.selecting && dataModel.settings.currentlyPlaying == widget.song),
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
          if(!dataModel.selecting)
            {
              dataModel.setCurrentlyPlaying(widget.song, widget.allowSelection ? dataModel.songs : dataModel.buildUpNext()),
            }
          else if(widget.allowSelection)
            {
              if(dataModel.selectedIndices.contains(widget.index))
                {
                  dataModel.selectedSongs.remove(widget.song),
                  dataModel.selectedIndices.remove(widget.index),
                  dataModel.setSelecting(),
                }
              else
                {
                  dataModel.selectedSongs.add(widget.song),
                  dataModel.selectedIndices.add(widget.index),
                  dataModel.setSelecting(),
                }
            }
        },
        onLongPress: () => {
          if(widget.allowSelection)
            {
              if(dataModel.selectedSongs.contains(widget.song))
                {
                  dataModel.selectedSongs.remove(widget.song),
                  dataModel.selectedIndices.remove(widget.index),
                  dataModel.setSelecting(),
                }
              else
                {
                  dataModel.selectedSongs.add(widget.song),
                  dataModel.selectedIndices.add(widget.index),
                  dataModel.setSelecting(),
                }
            }
        },
      ),
    );
  }

}
