import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
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
    ScrollController myScrollController = ScrollController();
    Album album = dataModel.albums[index];
    return Scaffold(
        appBar: dataModel.selectedIndices.length > 0 ? AppBar(automaticallyImplyLeading: false,
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
                  child: DraggableScrollbar.arrows(
                    backgroundColor: Theme.of(context).primaryColor,
                    controller: myScrollController,
                    child: ListView.builder(
                      controller: myScrollController,
                        itemBuilder: (_, index) {
                          //At the top of the list display the album art
                          if(index == 0)
                            {
                              return Column(children: [
                                InkWell(child: Hero(tag: "album_art", child: album.albumArt == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(album.albumArt))), onTap: () =>
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
                                  AlbumDetailsListItem(song: song, album: album, index: index - 1)
                                ],
                              );
                            }
                          return AlbumDetailsListItem(song: song, album: album, index: index - 1);
                        },
                        itemCount: album.songs.length + 1,
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}

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
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: ListTile(
        selected: dataModel.selectedIndices.contains(widget.album.songs.indexOf(widget.song)) || (dataModel.selectedIndices.length == 0 && dataModel.settings.upNext.length == widget.album.songs.length && dataModel.settings.upNext[dataModel.settings.playingIndex] == widget.song) ,
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
          if(dataModel.selectedIndices.length == 0)
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