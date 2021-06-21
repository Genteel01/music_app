import 'package:flutter/material.dart';
import 'package:music_app/ArtistDetails.dart';
import 'package:provider/provider.dart';

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
                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                        child: Align(alignment: Alignment.center,
                          child: ListTile(
                            selected: dataModel.selectedIndices.contains(index),
                            title: Text(artist.name),
                            trailing: Text(artist.songs.length.toString() + " tracks"),
                            leading: SizedBox(width: 50, height: 50, child: !artist.songs.any((element) => dataModel.getAlbumArt(element) != null) ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != null))!)),
                            //leading: SizedBox(width: 50, height: 50, child: dataModel.getAlbumArt(artist.songs[0]) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs[0])!)),
                            onTap: () async => {
                              if(!dataModel.selecting)
                                {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ArtistDetails(index: index);
                                      }))
                                }
                              else
                                {
                                  if(dataModel.selectedIndices.contains(index))
                                    {
                                      dataModel.selectedArtists.remove(artist),
                                      dataModel.selectedIndices.remove(index),
                                      dataModel.setSelecting(),
                                    }
                                  else
                                    {
                                      dataModel.selectedArtists.add(artist),
                                      dataModel.selectedIndices.add(index),
                                      dataModel.setSelecting(),
                                    }
                                }
                            },
                            onLongPress: () => {
                              if(dataModel.selectedIndices.contains(index))
                                {
                                  dataModel.selectedArtists.remove(artist),
                                  dataModel.selectedIndices.remove(index),
                                  dataModel.setSelecting(),
                                }
                              else
                                {
                                  dataModel.selectedArtists.add(artist),
                                  dataModel.selectedIndices.add(index),
                                  dataModel.setSelecting(),
                                }
                            },
                          ),
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