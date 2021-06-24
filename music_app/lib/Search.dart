import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'Album.dart';
import 'AlbumDetails.dart';
import 'Artist.dart';
import 'ArtistDetails.dart';
import 'DataModel.dart';
import 'Song.dart';

class SearchResults extends StatelessWidget {

  SearchResults({Key? key}) : super();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildWidget
    );
  }

  List<Song> buildUpNext(List<Object> results)
  {
    List<Song> newList = [];
    results.forEach((element) {
      if(element.runtimeType == Song)
        {
          newList.add(element as Song);
        }
    });
    return newList;
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _) {
    return Expanded(
      child: Container(decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
        //TODO split the list by item type
        child: ListView.builder(
            itemBuilder: (_, index) {
              var item = dataModel.searchResults[index];
              //If the item is a song display a song list tile
              if(item.runtimeType == Song)
                {
                  Song song = item as Song;
                  return Container(height: 70, decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                    child: ListTile(
                      selected: dataModel.selectedIndices.contains(index),
                      title: Text(song.name),
                      subtitle: Text(song.album),
                      trailing: Text(song.durationString()),
                      leading: SizedBox(width: 50, height: 50,child: dataModel.getAlbumArt(song) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(song)!)),
                      onTap: () => {
                          dataModel.setCurrentlyPlaying(song, buildUpNext(dataModel.searchResults)),
                      },
                    ),
                  );
                }
              //If the item is an album display an album list tile
              else if(item.runtimeType == Album)
                {
                  Album album = item as Album;
                  return Container(height: 70, decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                    child: ListTile(
                      selected: dataModel.selectedIndices.contains(index),
                      title: Text(album.name),
                      trailing: Text(album.songs.length.toString() + " tracks"),
                      subtitle: Text(album.albumArtist),
                      leading: SizedBox(width: 50, height: 50, child: album.albumArt == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(album.albumArt!)),
                      onTap: () => {
                          WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus(),
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return AlbumDetails(index: dataModel.albums.indexOf(album));
                              })).then((value) {
                            dataModel.clearSelections();
                          })
                      },
                    ),
                  );
                }
              //If it is neither display an artist list tile
              else
                {
                  Artist artist = item as Artist;
                  return Container(height: 70, decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 0.5, color: Colors.grey), bottom: BorderSide(width: 0.25, color: Colors.grey))),
                    child: Align(alignment: Alignment.center,
                      child: ListTile(
                        selected: dataModel.selectedIndices.contains(index),
                        title: Text(artist.name),
                        trailing: Text(artist.songs.length.toString() + " tracks"),
                        leading: SizedBox(width: 50, height: 50, child: !artist.songs.any((element) => dataModel.getAlbumArt(element) != null) ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(artist.songs.firstWhere((element) => dataModel.getAlbumArt(element) != null))!)),
                        onTap: () => {
                          WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus(),
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ArtistDetails(index: dataModel.artists.indexOf(artist));
                                })).then((value) {
                              dataModel.clearSelections();
                            })
                        },
                      ),
                    ),
                  );
                }
            },
            itemCount: dataModel.searchResults.length
        ),
      ),
    );
  }
}