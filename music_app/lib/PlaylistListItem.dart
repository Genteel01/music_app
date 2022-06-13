import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'DataModel.dart';
import 'Playlist.dart';
import 'PlaylistDetails.dart';
import 'Values.dart';

class PlaylistListItem extends StatelessWidget {
  const PlaylistListItem({
    Key? key,
    required this.addingToPlaylist,
    required this.playlist,
    required this.index
  }) : super(key: key);

  final bool addingToPlaylist;
  final Playlist playlist;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Container(height: Dimens.listItemSize, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), bottom: BorderSide(width: Dimens.thinBorderSize, color: Colours.listDividerColour))),
      child: Row(
        children: [
          if (dataModel.inSelectMode) Checkbox(value: dataModel.selectedIndices.contains(dataModel.playlists.indexOf(playlist)), onChanged: (value) {
            if(!addingToPlaylist)
            {
              dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
            }
          }),
          Expanded(
            child: ListTile(
              selected: !addingToPlaylist && dataModel.selectedIndices.contains(dataModel.playlists.indexOf(playlist)),
              title: Text(playlist.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
              subtitle: Text(Strings.timeFormat(dataModel.calculateDuration(playlist.songs))),
              trailing: Text(playlist.songs.length == 1 ? "${playlist.songs.length} Track" : "${playlist.songs.length} Tracks"),
              leading: AspectRatio(aspectRatio: 1.0/1.0,
                child: Hero(tag: playlist.name, child:
                !playlist.songs.any((element) => dataModel.getAlbumArt(element) != "") ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(playlist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != "")))),
                ),
              ),
              onTap: () {
                if(addingToPlaylist)
                {
                  dataModel.addToPlaylist(playlist);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Songs Added to Playlist"),
                  ));
                  Navigator.pop(context);
                }
                else
                {
                  if(!dataModel.inSelectMode)
                  {
                    Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => PlaylistDetails(index: index))
                      /*MaterialPageRoute(
                            builder: (context) {
                              return PlaylistDetails(index: index - 1);
                          })*/
                    ).then((value) {
                      dataModel.clearSelections();
                    });
                  }
                  else
                  {
                    dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
                  }
                }
              },
              onLongPress: () {
                if(!addingToPlaylist)
                {
                  dataModel.toggleSelection(dataModel.playlists.indexOf(playlist), Playlist);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}