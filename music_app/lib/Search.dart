import 'package:flutter/material.dart';
import 'package:music_app/AlbumList.dart';
import 'package:music_app/ArtistList.dart';
import 'package:music_app/SongList.dart';
import 'package:provider/provider.dart';


import 'Album.dart';
import 'Artist.dart';
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
  final TextEditingController searchController = TextEditingController();
  Widget buildWidget(BuildContext context, DataModel dataModel, _) {
    return Scaffold(
          appBar: AppBar(title: Text("Search"), actions: [
            SizedBox(width: 200,
              child: TextField(cursorColor: Colors.white,controller: searchController, decoration: InputDecoration(hintText: "Search"), onChanged: (s) => {
              dataModel.getSearchResults(s)
          },),
            )
          ]
            ,),
          body: Column(
            children: <Widget>[Expanded(
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
                        int counter = 0;
                        while(counter < dataModel.searchResults.length && dataModel.searchResults[counter].runtimeType != Song)
                          {
                            counter++;
                          }
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                              child: Text("Songs"),
                            ),
                            SongListItem(song: song, allowSelection: false, futureSongs: dataModel.buildUpNext(), index: index - counter, playSongs: true,),
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
                            AlbumListItem(album: album, allowSelection: false, goToDetails: true,),
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
                            ArtistListItem(artist: artist, allowSelection: false, goToDetails: true,),
                          ],
                        );
                      }
                    }
                  //If the item is a song display a song list tile
                  if(item.runtimeType == Song)
                    {
                      Song song = item as Song;
                      int counter = 0;
                      while(counter < dataModel.searchResults.length && dataModel.searchResults[counter].runtimeType != Song)
                      {
                        counter++;
                      }
                      return SongListItem(song: song, allowSelection: false, futureSongs: dataModel.buildUpNext(), index: index - counter, playSongs: true,);
                    }
                  //If the item is an album display an album list tile
                  else if(item.runtimeType == Album)
                    {
                      Album album = item as Album;
                      return AlbumListItem(album: album, allowSelection: false, goToDetails: true,);
                    }
                  //If it is neither display an artist list tile
                  else
                    {
                      Artist artist = item as Artist;
                      return ArtistListItem(artist: artist, allowSelection: false, goToDetails: true,);
                    }
                },
                itemCount: dataModel.searchResults.length
            ),
        ),
      )],
          )
    );
  }
}