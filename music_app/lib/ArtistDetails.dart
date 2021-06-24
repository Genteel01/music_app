import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'Artist.dart';
import 'DataModel.dart';

class ArtistDetails extends StatelessWidget {
  final int index;

  ArtistDetails({required this.index}) : super();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Artist artist = dataModel.artists[index];
    return Scaffold(
        appBar: dataModel.selecting ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(artist: artist,),
        ) : AppBar(
          title: Text(artist.name),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        var song = artist.songs[index];
                        //If you're at a new album print an album heading
                        if(index == 0 || song.album != artist.songs[index - 1].album)
                        {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                child: Text(song.album),
                              ),
                              Container(height: 70, decoration: BoxDecoration(
                                  border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                                child: ListTile(
                                  selected: dataModel.selectedIndices.contains(index),
                                  title: Text(song.name),
                                  subtitle: Text(song.album),
                                  trailing: Text(song.durationString()),
                                  leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(song)!)),
                                  onTap: () async => {
                                    if(!dataModel.selecting)
                                      {
                                        dataModel.setCurrentlyPlaying(song, artist.songs),
                                      }
                                    else
                                      {
                                        if(dataModel.selectedIndices.contains(index))
                                          {
                                            dataModel.selectedSongs.remove(song),
                                            dataModel.selectedIndices.remove(index),
                                            dataModel.setSelecting(),
                                          }
                                        else
                                          {
                                            dataModel.selectedSongs.add(song),
                                            dataModel.selectedIndices.add(index),
                                            dataModel.setSelecting(),
                                          }
                                      }
                                  },
                                  onLongPress: () => {
                                    if(dataModel.selectedSongs.contains(song))
                                      {
                                        dataModel.selectedSongs.remove(song),
                                        dataModel.selectedIndices.remove(index),
                                        dataModel.setSelecting(),
                                      }
                                    else
                                      {
                                        dataModel.selectedSongs.add(song),
                                        dataModel.selectedIndices.add(index),
                                        dataModel.setSelecting(),
                                      }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return Container(height: 70, decoration: BoxDecoration(
                            border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                          child: ListTile(
                            selected: dataModel.selectedIndices.contains(index),
                            title: Text(song.name),
                            subtitle: Text(song.album),
                            trailing: Text(song.durationString()),
                            leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(song)!)),
                            onTap: () async => {
                              if(!dataModel.selecting)
                                {
                                  dataModel.setCurrentlyPlaying(song, artist.songs),
                                }
                              else
                                {
                                  if(dataModel.selectedIndices.contains(index))
                                    {
                                      dataModel.selectedSongs.remove(song),
                                      dataModel.selectedIndices.remove(index),
                                      dataModel.setSelecting(),
                                    }
                                  else
                                    {
                                      dataModel.selectedSongs.add(song),
                                      dataModel.selectedIndices.add(index),
                                      dataModel.setSelecting(),
                                    }
                                }
                            },
                            onLongPress: () => {
                              if(dataModel.selectedSongs.contains(song))
                                {
                                  dataModel.selectedSongs.remove(song),
                                  dataModel.selectedIndices.remove(index),
                                  dataModel.setSelecting(),
                                }
                              else
                                {
                                  dataModel.selectedSongs.add(song),
                                  dataModel.selectedIndices.add(index),
                                  dataModel.setSelecting(),
                                }
                            },
                          ),
                        );
                      },
                      itemCount: artist.songs.length
                  ),
                ),
              )
            ]
        )
    );
  }
}