import 'package:flutter/material.dart';
import 'package:music_app/SongList.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumArtView.dart';
import 'DataModel.dart';
import 'Song.dart';

class AlbumDetails extends StatelessWidget {
  final int index;

  AlbumDetails({required this.index}) : super();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Album album = dataModel.albums[index];
    return Scaffold(
        appBar: dataModel.selecting ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(album: album,),
        ) : AppBar(
          title: Text(album.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        //At the top of the list display the album art
                        if(index == 0)
                          {
                            return Column(children: [
                              InkWell(child: Hero(tag: "album_art", child: album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(album.albumArt!)), onTap: () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return AlbumArtView(image: album.albumArt);
                                      })),),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text(album.albumArtist), Text("Tracks: " + album.songs.length.toString())],),
                              ShuffleButton(dataModel: dataModel, futureSongs: album.songs)
                            ],);
                          }
                        var song = album.songs[index - 1];
                        //print the discnumber as a heading if you are at the start of the new disc
                        if(index == 1 || song.discNumber != album.songs[index - 2].discNumber)
                          {
                            return Column(
                              children: [
                                //Disc number
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                  child: Text("Disc " + song.discNumber.toString()),
                                ),
                                //Song list tile
                                AlbumDetailsListItem(song: song, index: index, album: album,)
                              ],
                            );
                          }
                        return AlbumDetailsListItem(song: song, index: index, album: album,);
                      },
                      itemCount: album.songs.length + 2
                  ),
                ),
              )
            ]
        )
    );
  }
}

class AlbumDetailsListItem extends StatefulWidget {
  const AlbumDetailsListItem({Key? key, required this.song, required this.index, required this.album}) : super(key: key);
  final Song song;
  final int index;
  final Album album;

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
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: ListTile(
        selected: dataModel.selectedIndices.contains(widget.index),
        title: Text(widget.song.name),
        subtitle: Text(widget.song.artist),
        trailing: Text(widget.song.durationString()),
        leading: Text(widget.song.trackNumber.toString()),
        onTap: () => {
          if(!dataModel.selecting)
            {
              dataModel.setCurrentlyPlaying(widget.song, widget.album.songs),
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
      ),
    );
  }
}