import 'package:flutter/material.dart';
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
        appBar: dataModel.selecting ? AppBar(automaticallyImplyLeading: false,
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
                        var song = artist.songs[index];
                        //If you're at a new album print an album heading
                        if(index == 0 || song.album != artist.songs[index - 1].album)
                        {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                child: Text(song.album),
                              ),
                              Container(height: 70, decoration: BoxDecoration(
                                  border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                                child: ArtistDetailsListItem(song: song, index: index, artist: artist,),
                              ),
                            ],
                          );
                        }
                        return Container(height: 70, decoration: BoxDecoration(
                            border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                          child: ArtistDetailsListItem(song: song, index: index, artist: artist,),
                        );
                      },
                      itemCount: artist.songs.length
                  ),
                ),
              )
            ]
        )
    );
  }
}

class ArtistDetailsListItem extends StatefulWidget {
  const ArtistDetailsListItem({Key? key, required this.song, required this.index, required this.artist}) : super(key: key);
  final Song song;
  final int index;
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
    return ListTile(
      selected: dataModel.selectedIndices.contains(widget.index),
      title: Text(widget.song.name),
      subtitle: Text(widget.song.album),
      trailing: Text(widget.song.durationString()),
      leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(widget.song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(widget.song)!)),
      onTap: () => {
        if(!dataModel.selecting)
          {
            dataModel.setCurrentlyPlaying(widget.song, widget.artist.songs),
          }
        else
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
      },
    );
  }
}