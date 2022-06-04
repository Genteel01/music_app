import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'Artist.dart';
import 'DataModel.dart';
import 'Playlist.dart';
import 'PlaylistList.dart';

class SelectingAppBarTitle extends StatefulWidget {
  const SelectingAppBarTitle({Key? key, this.album, this.artist, this.playlist, this.rightButtonReplacement}) : super(key: key);
  final Album? album;
  final Artist? artist;
  final Playlist? playlist;
  final Widget? rightButtonReplacement;
  @override
  _SelectingAppBarTitleState createState() => _SelectingAppBarTitleState();
}

class _SelectingAppBarTitleState extends State<SelectingAppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton(child: Text(dataModel.returnAllSelected(widget.album, widget.artist, widget.playlist) ? "Clear" : "All"), onPressed: () => {
              dataModel.returnAllSelected(widget.album, widget.artist, widget.playlist) ? dataModel.clearSelections() : dataModel.selectAll(widget.album, widget.artist, widget.playlist)
            },),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(dataModel.selectedIndices.length.toString() + " Selected"),
            ),
          ],
        ),
        widget.rightButtonReplacement != null ? widget.rightButtonReplacement! :
        ElevatedButton(child: Text(dataModel.selectionType == Playlist || widget.playlist != null ? "Remove" : "Add To"), onPressed: () => {
          if(dataModel.selectionType == Playlist)
            {
              dataModel.deletePlaylists(),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Playlists Deleted"),
              )),
            }
          else if(widget.playlist != null)
            {
              dataModel.removeFromPlaylist(widget.playlist!),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Songs Removed From Playlist"),
              )),
            }
          else
            {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(0))),
                builder: (BuildContext context) {
                  return Padding(
                    padding: MediaQuery
                        .of(context)
                        .viewInsets,
                    child: Container(
                      height: 400,
                      //color: Colors.amber,
                      child: Flex(direction: Axis.vertical, children: [
                        PlaylistListBuilder(addingToPlaylist: true,)
                      ]),
                    ),
                  );
                },
              )
            }
        },),
      ],
    );
  }
}