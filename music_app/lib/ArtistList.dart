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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[if(dataModel.loading) CircularProgressIndicator() else
            Expanded(
              child: Container(decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                child: ListView.builder(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (_, index) {
                      var artist = dataModel.artists[index];
                      if(artist.songs.length == 0)
                      {
                        return Container(height: 0);
                      }
                      return ArtistListItem(artist: artist, index: index, allowSelection: true,);
                    },
                    itemCount: dataModel.artists.length
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
  const ArtistListItem({Key? key, required this.artist, required this.index, required this.allowSelection}) : super(key: key);
  final Artist artist;
  final int index;
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
          selected: dataModel.selectedIndices.contains(widget.index),
          title: Text(widget.artist.name),
          trailing: Text(widget.artist.songs.length.toString() + " tracks"),
          leading: SizedBox(width: 50, height: 50, child: !widget.artist.songs.any((element) => dataModel.getAlbumArt(element) != null) ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(widget.artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != null))!)),
          onTap: () async => {
            if(!dataModel.selecting)
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
                if(dataModel.selectedIndices.contains(widget.index))
                  {
                    dataModel.selectedArtists.remove(widget.artist),
                    dataModel.selectedIndices.remove(widget.index),
                    dataModel.setSelecting(),
                  }
                else
                  {
                    dataModel.selectedArtists.add(widget.artist),
                    dataModel.selectedIndices.add(widget.index),
                    dataModel.setSelecting(),
                  }
              }
          },
          onLongPress: () => {
            if(widget.allowSelection)
              {
                if(dataModel.selectedIndices.contains(widget.index))
                  {
                    dataModel.selectedArtists.remove(widget.artist),
                    dataModel.selectedIndices.remove(widget.index),
                    dataModel.setSelecting(),
                  }
                else
                  {
                    dataModel.selectedArtists.add(widget.artist),
                    dataModel.selectedIndices.add(widget.index),
                    dataModel.setSelecting(),
                  }
              }
          },
        ),
      ),
    );
  }
}