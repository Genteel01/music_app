import 'package:flutter/material.dart';
import 'package:music_app/AlbumList.dart';
import 'package:music_app/ArtistList.dart';
import 'package:music_app/SongList.dart';
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

  Widget buildWidget(BuildContext context, DataModel dataModel, _) {
    return Expanded(
      child: Container(decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
        child: ListView.builder(
            itemBuilder: (_, index) {
              var item = dataModel.searchResults[index];
              //If you're at a new category of results print the result type as a heading
              if(index == 0 || item.runtimeType != dataModel.searchResults[index - 1].runtimeType)
                {
                  //If the item is a song display a song list tile
                  if(item.runtimeType == Song)
                  {
                    Song song = item as Song;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                          child: Text("Songs"),
                        ),
                        SongListItem(song: song, index: index, allowSelection: false),
                      ],
                    );
                  }
                  //If the item is an album display an album list tile
                  else if(item.runtimeType == Album)
                  {
                    Album album = item as Album;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                          child: Text("Albums"),
                        ),
                        AlbumListItem(album: album, index: index, allowSelection: false),
                      ],
                    );
                  }
                  //If it is neither display an artist list tile
                  else
                  {
                    Artist artist = item as Artist;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                          child: Text("Artists"),
                        ),
                        ArtistListItem(artist: artist, index: index, allowSelection: false),
                      ],
                    );
                  }
                }
              //If the item is a song display a song list tile
              if(item.runtimeType == Song)
                {
                  Song song = item as Song;
                  return SongListItem(song: song, index: index, allowSelection: false);
                }
              //If the item is an album display an album list tile
              else if(item.runtimeType == Album)
                {
                  Album album = item as Album;
                  return AlbumListItem(album: album, index: index, allowSelection: false);
                }
              //If it is neither display an artist list tile
              else
                {
                  Artist artist = item as Artist;
                  return ArtistListItem(artist: artist, index: index, allowSelection: false);
                }
            },
            itemCount: dataModel.searchResults.length
        ),
      ),
    );
  }
}