import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/SortDropdown.dart';
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
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
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
                          if(widget.playSongs)
                            {
                              return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ShuffleButton(dataModel: dataModel, futureSongs: dataModel.songs,),
                                  SortDropdown(),
                                ],
                              );
                            }
                          else
                            {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(alignment: Alignment.centerLeft, child: Text(dataModel.songs.length == 1 ? dataModel.songs.length.toString() + " Song" : dataModel.songs.length.toString() + " Songs", style: TextStyle(fontSize: 16,),)),
                              );
                            }
                        }
                        var song = dataModel.songs[index - 1];
                        return SongListItem(song: song, allowSelection: true, futureSongs: dataModel.songs, index: index - 1, playSongs: widget.playSongs,);
                      },
                      itemCount: dataModel.songs.length + 1,
                      itemExtent: 70,
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