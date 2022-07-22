import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/SortDropdown.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'DirectoriesMenuListItem.dart';
import 'ShuffleButton.dart';
import 'SongListItem.dart';


class SongList extends StatefulWidget {
  const SongList({Key? key, required this.playSongs}) : super(key: key);
  final bool playSongs;
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
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
                          if(widget.playSongs && !dataModel.inSelectMode)
                            {
                              return Container(height: Dimens.listItemSize,
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ShuffleButton(dataModel: dataModel, futureSongs: dataModel.songs,),
                                    SortDropdown(),
                                  ],
                                ),
                              );
                            }
                          else
                            {
                              return Container(height: Dimens.listItemSize,
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(Dimens.xSmall),
                                      child: Align(alignment: Alignment.centerLeft, child: Text(dataModel.songs.length == 1 ? "${dataModel.songs.length} Song" : "${dataModel.songs.length} Songs", style: TextStyle(fontSize: Dimens.listHeaderFontSize,),)),
                                    ),
                                    if(!dataModel.inSelectMode) SortDropdown(),
                                  ],
                                ),
                              );
                            }
                        }
                        var song = dataModel.songs[index - 1];
                        return SongListItem(song: song, allowSelection: true, futureSongs: dataModel.songs, index: index - 1, playSongs: widget.playSongs,);
                      },
                      itemCount: dataModel.songs.length + 1,
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