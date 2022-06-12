import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppBarTitle.dart';
import 'Artist.dart';
import 'ArtistDetailsListItem.dart';
import 'CurrentlyPlayingBar.dart';
import 'DataModel.dart';
import 'ListHeader.dart';
import 'ShuffleButton.dart';
import 'Values.dart';

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
    ScrollController myScrollController = ScrollController();
    Artist artist = dataModel.artists[index];
    return Scaffold(
        appBar: dataModel.isSelecting() ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(artist: artist,),
        ) : AppBar(
          title: Text(artist.name),
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
                          if(index == 0)
                          {
                            return ShuffleButton(dataModel: dataModel, futureSongs: artist.songs);
                          }
                          var song = artist.songs[index - 1];
                          //If you're at a new album print an album heading
                          if(index == 1 || song.album != artist.songs[index - 2].album)
                          {
                            return Column(
                              children: [
                                ListHeader(text: song.album),
                                ArtistDetailsListItem(song: song, artist: artist, index: index - 1),
                              ],
                            );
                          }
                          return ArtistDetailsListItem(song: song, artist: artist, index: index - 1);
                        },
                        itemCount: artist.songs.length + 1,
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}