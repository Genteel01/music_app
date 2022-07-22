import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'ArtistListItem.dart';
import 'DataModel.dart';
import 'DirectoriesMenuListItem.dart';

class ArtistList extends StatefulWidget {
  const ArtistList({Key? key, required this.goToDetails}) : super(key: key);
  final bool goToDetails;
  @override
  _ArtistListState createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
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
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    controller: myScrollController,
                      itemBuilder: (_, index) {
                        if(index == 0)
                        {
                          if(dataModel.songs.length == 0)
                          {
                            return DirectoriesMenuListItem();
                          }
                          return Container(height: Dimens.listItemSize,
                            child: Padding(
                              padding: const EdgeInsets.all(Dimens.xSmall),
                              child: Align(alignment: Alignment.centerLeft, child: Text(dataModel.artists.length == 1 ? dataModel.artists.length.toString() + " Artist" : dataModel.artists.length.toString() + " Artists", style: TextStyle(fontSize: Dimens.listHeaderFontSize,),)),
                            ),
                          );
                        }
                        var artist = dataModel.artists[index - 1];
                        if(artist.songs.length == 0)
                        {
                          return Container(height: 0);
                        }
                        return ArtistListItem(artist: artist, allowSelection: true, goToDetails: widget.goToDetails);
                      },
                      itemCount: dataModel.artists.length + 1,
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