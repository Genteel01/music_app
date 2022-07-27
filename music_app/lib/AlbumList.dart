import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'AlbumListItem.dart';
import 'DataModel.dart';
import 'DirectoriesMenuListItem.dart';
import 'DividedItem.dart';

class AlbumList extends StatefulWidget {
  const AlbumList({Key? key, required this.goToDetails}) : super(key: key);
  final bool goToDetails;
  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
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
                  border: Border(bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour),)),
                child: DraggableScrollbar.arrows(
                  backgroundColor: Theme.of(context).primaryColor,
                  controller: myScrollController,
                  child: ListView.builder(
                    controller: myScrollController,
                      itemBuilder: (_, index) {
                        if(index == 0)
                        {
                          if(dataModel.songs.length == 0)
                          {
                            return DirectoriesMenuListItem();
                          }
                          return Column(
                            children: [
                              Container(height: Dimens.listItemSize,
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimens.xSmall),
                                  child: Align(alignment: Alignment.centerLeft, child: Text(dataModel.albums.length == 1 ? "${dataModel.albums.length} Album" : "${dataModel.albums.length} Albums", style: TextStyle(fontSize: Dimens.listHeaderFontSize,),)),
                                ),
                              ),
                              Divider()
                            ],
                          );
                        }
                        var album = dataModel.albums[index - 1];
                        if(album.songs.length == 0)
                          {
                            return Container(height: 0);
                          }
                        return DividedItem(child: AlbumListItem(album: album, allowSelection: true, goToDetails: widget.goToDetails,));
                      },
                      itemCount: dataModel.albums.length + 1,
                      itemExtent: Dimens.listItemSize,
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
