import 'package:flutter/material.dart';
import 'package:music_app/SongList.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'Artist.dart';
import 'DataModel.dart';
import 'Song.dart';

class ArtistDetails extends StatelessWidget {
  final int index;

  ArtistDetails({required this.index}) : super();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Artist artist = dataModel.artists[index];
    return Scaffold(
        appBar: dataModel.selectedItems.length > 0 ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(artist: artist,),
        ) : AppBar(
          title: Text(artist.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        if(index == 0)
                        {
                          return ShuffleButton(dataModel: dataModel, futureSongs: artist.songs);
                        }
                        var song = artist.songs[index - 1];
                        //If you're at a new album print an album heading
                        if(index == 1 || song.album != artist.songs[index - 1].album)
                        {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                child: Text(song.album),
                              ),
                              ArtistDetailsListItem(song: song, artist: artist,),
                            ],
                          );
                        }
                        return ArtistDetailsListItem(song: song, artist: artist,);
                      },
                      itemCount: artist.songs.length + 1
                  ),
                ),
              )
            ]
        )
    );
  }
}

class ArtistDetailsListItem extends StatefulWidget {
  const ArtistDetailsListItem({Key? key, required this.song, required this.artist}) : super(key: key);
  final Song song;
  final Artist artist;

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
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: ListTile(
        selected: dataModel.selectedItems.contains(widget.song) || (dataModel.selectedItems.length == 0 && dataModel.settings.currentlyPlaying == widget.song),
        title: Text(widget.song.name),
        subtitle: Text(widget.song.album),
        trailing: dataModel.settings.currentlyPlaying == widget.song ? Row(mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.song.durationString()),
            Icon(Icons.play_arrow)
          ],
        ) : Text(widget.song.durationString()),
        leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(widget.song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(widget.song)!)),
        onTap: () => {
          if(dataModel.selectedItems.length == 0)
            {
              dataModel.setCurrentlyPlaying(widget.song, widget.artist.songs),
            }
          else
            {
              dataModel.toggleSelection(widget.song)
            }
        },
        onLongPress: () => {
          dataModel.toggleSelection(widget.song)
        },
      ),
    );
  }
}