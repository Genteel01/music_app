import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ArtistDetails.dart';
import 'package:provider/provider.dart';

import 'Artist.dart';
import 'DataModel.dart';
class ArtistList extends StatefulWidget {
  const ArtistList({Key? key}) : super(key: key);

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
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                child: DraggableScrollbar.arrows(
                  backgroundColor: Theme.of(context).primaryColor,
                  controller: myScrollController,
                  child: ListView.builder(
                    controller: myScrollController,
                      itemBuilder: (_, index) {
                        if(index == 0)
                        {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(dataModel.artists.length.toString() + " artists"),
                          );
                        }
                        var artist = dataModel.artists[index - 1];
                        if(artist.songs.length == 0)
                        {
                          return Container(height: 0);
                        }
                        return ArtistListItem(artist: artist, allowSelection: true,);
                      },
                      itemCount: dataModel.artists.length + 1,
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

class ArtistListItem extends StatefulWidget {
  const ArtistListItem({Key? key, required this.artist, required this.allowSelection}) : super(key: key);
  final Artist artist;
  //Selection will be disabled if the item is being shown in search results
  final bool allowSelection;
  @override
  _ArtistListItemState createState() => _ArtistListItemState();
}

class _ArtistListItemState extends State<ArtistListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Container(height: 70, decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
      child: Align(alignment: Alignment.center,
        child: ListTile(
          selected: dataModel.selectedIndices.contains(dataModel.artists.indexOf(widget.artist)),
          title: Text(widget.artist.name),
          trailing: Text(widget.artist.songs.length.toString() + " tracks"),
          leading: SizedBox(width: 50, height: 50, child: !widget.artist.songs.any((element) => dataModel.getAlbumArt(element) != null) ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(widget.artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != null))!)),
          onTap: () async => {
            if(dataModel.selectedIndices.length == 0)
              {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ArtistDetails(index: dataModel.artists.indexOf(widget.artist));
                    })).then((value) {
                  dataModel.clearSelections();
                })
              }
            else if(widget.allowSelection)
              {
                dataModel.toggleSelection(dataModel.artists.indexOf(widget.artist), Artist)
              }
          },
          onLongPress: () => {
            if(widget.allowSelection)
              {
                dataModel.toggleSelection(dataModel.artists.indexOf(widget.artist), Artist)
              }
          },
        ),
      ),
    );
  }
}