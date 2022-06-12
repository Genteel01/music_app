import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ListHeader.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumArtView.dart';
import 'AlbumDetailsListItem.dart';
import 'CurrentlyPlayingBar.dart';
import 'DataModel.dart';
import 'AppBarTitle.dart';
import 'ShuffleButton.dart';

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
        appBar: dataModel.isSelecting() ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(album: album,),
        ) : AppBar(
          title: Text(album.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour),)),
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
                                InkWell(child: Hero(tag: "album_art", child: album.albumArt == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(album.albumArt))), onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AlbumArtView(image: album.albumArt);
                                        }));
                                    },
                                ),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text(album.albumArtist), Text("Tracks: " + album.songs.length.toString())],),
                                ShuffleButton(dataModel: dataModel, futureSongs: album.songs)
                              ],);
                            }
                          var song = album.songs[index - 1];
                          //print the disc number as a heading if you are at the start of the new disc
                          if(index == 1 || song.discNumber != album.songs[index - 2].discNumber)
                            {
                              return Column(
                                children: [
                                  //Disc number
                                  ListHeader(text: "Disc ${song.discNumber}"),
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