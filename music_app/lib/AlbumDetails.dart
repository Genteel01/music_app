import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumArtView.dart';
import 'DataModel.dart';

class AlbumDetails extends StatelessWidget {
  final int index;

  AlbumDetails({required this.index}) : super();
  final filterController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Album album = dataModel.albums[index];
    return Scaffold(
        appBar: AppBar(
          title: Text(album.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              //TODO split the list by disc number
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        if(index == 0)
                          {
                            return Column(children: [
                              InkWell(child: Hero(tag: "album_art", child: album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(album.albumArt!)), onTap: () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return AlbumArtView(image: album.albumArt);
                                      })),),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text(album.albumArtist), Text("Tracks: " + album.songs.length.toString())],),
                            ],);
                          }
                        var song = album.songs[index - 1];

                        return Container(height: 70, decoration: BoxDecoration(
                            border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                          child: ListTile(
                            title: Text(song.name),
                            subtitle: Text(song.artist),
                            trailing: Text(song.durationString()),
                            leading: Text(song.trackNumber.toString()),
                            onTap: () async => {
                              dataModel.setCurrentlyPlaying(song, dataModel.songs),
                            },
                          ),
                        );
                      },
                      itemCount: album.songs.length + 1
                  ),
                ),
              )
            ]
        )
    );
  }
}