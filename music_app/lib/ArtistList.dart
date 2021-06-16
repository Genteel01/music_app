import 'package:flutter/material.dart';
import 'package:music_app/Song.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
//TODO make the database fetch just grab the file paths. The list can turn them into songs.
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
//TODO replace the default image with one that I made
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

                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                        child: ListTile(
                          title: Text(artist.name),
                          subtitle: Text(artist.songs.length.toString() + " tracks"),
                          leading: SizedBox(width: 50, height: 50, child: !artist.songs.any((element) => dataModel.getAlbumArt(element) != null) ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != null))!)),
                          //leading: SizedBox(width: 50, height: 50, child: dataModel.getAlbumArt(artist.songs[0]) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs[0])!)),
                          onTap: () => {

                          },
                        ),
                      );
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