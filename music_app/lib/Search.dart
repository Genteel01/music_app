import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';


import 'Album.dart';
import 'AlbumListItem.dart';
import 'Artist.dart';
import 'ArtistListItem.dart';
import 'DataModel.dart';
import 'ListHeader.dart';
import 'Song.dart';
import 'SongListItem.dart';

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
    dataModel.searchResults.forEach((element) {
      
    });
    int artistCount = dataModel.searchResults.lastIndexWhere((element) => element.runtimeType == Artist) + 1;
    int albumCount = dataModel.searchResults.lastIndexWhere((element) => element.runtimeType == Album) - artistCount + 1;
    int songCount = dataModel.searchResults.lastIndexWhere((element) => element.runtimeType == Song) - albumCount - artistCount + 1;
    return Scaffold(
          appBar: AppBar(title: Text("Search"), actions: [
            Padding(
              padding: const EdgeInsets.only(right: Dimens.xSmall),
              child: SizedBox(width: Dimens.searchTextFieldWidth,
                child: TextField(controller: searchController, decoration: InputDecoration(hintText: "Search",), onChanged: (s) {
                dataModel.getSearchResults(s);
          },),
              ),
            )
          ]
            ,),
          body: Column(
            children: <Widget>[Expanded(
        child: Container(decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour), top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.listDividerColour),)),
            child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
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
                            ListHeader(text: "Songs ($songCount)"),
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
                            ListHeader(text: "Albums ($albumCount)"),
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
                            ListHeader(text: "Artists ($artistCount)"),
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