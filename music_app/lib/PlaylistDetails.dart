import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/SongList.dart';
import 'package:music_app/main.dart';
import 'package:provider/provider.dart';


import 'AlbumList.dart';
import 'ArtistList.dart';
import 'DataModel.dart';
import 'Playlist.dart';
//TODO do the menu (with settings, rename, delete, add to playlist and reorder options)
class PlaylistDetails extends StatelessWidget {
  final int index;

  PlaylistDetails({required this.index}) : super();
  final filterController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    Playlist playlist = dataModel.playlists[index];
    ScrollController myScrollController = ScrollController();
    void selectMenuButton(String button)
    {
      switch (button)
      {
        case "Rename":
          final playlistNameController = TextEditingController();
          playlistNameController.text = playlist.name;
          showDialog<bool>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text("New Playlist"),
                    content: TextField(controller: playlistNameController, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: playlist.name),),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Create'),
                      ),
                    ],
                  )
          ).then((value) =>
          {
            if(value != null && value)
              {
                dataModel.renamePlaylist(playlist, playlistNameController.text)
              }
          });
          break;
        case "Reorder":
          break;
        case "Delete":
          dataModel.removePlaylist(playlist);
          Navigator.pop(context);
          break;
        case "Add to Playlist":
          Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddToPlaylist();
              })).then((value) {
            if(value != null && value)
            {
              dataModel.addToPlaylist(playlist);
            }
            dataModel.clearSelections();
          });
          break;
      }
    }
    return Scaffold(
        appBar: dataModel.selectedIndices.length > 0 ? AppBar(automaticallyImplyLeading: false,
          title: SelectingAppBarTitle(playlist: playlist,),
        ) : AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(playlist.name),
              PopupMenuButton<String>(
                onSelected: selectMenuButton,
                itemBuilder: (BuildContext context) {
                  return {"Rename", "Reorder", "Delete", "Add to Playlist"}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: CurrentlyPlayingBar(),
        body: Column(
            children: <Widget>[
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
                            return ShuffleButton(dataModel: dataModel, futureSongs: playlist.songs);
                          }
                          var song = playlist.songs[index - 1];

                          return SongListItem(song: song, allowSelection: true, futureSongs: playlist.songs, index: index - 1, playSongs: true,);
                        },
                        itemCount: playlist.songs.length + 1,
                      itemExtent: 70,
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}

class AddToPlaylist extends StatefulWidget {
  const AddToPlaylist({Key? key}) : super(key: key);

  @override
  _AddToPlaylistState createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  final List<Tab> myTabs = [
    Tab(child: Row(children: [Icon(Icons.music_note), Text(" Tracks")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.person), Text(" Artists")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.album), Text(" Albums")],mainAxisAlignment: MainAxisAlignment.center,),),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildWidget
    );
  }

  Widget buildWidget(BuildContext context, DataModel dataModel, _) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: dataModel.selectedIndices.length > 0 ? AppBar(automaticallyImplyLeading: false,
            title: SelectingAppBarTitle(rightButtonReplacement: ElevatedButton.icon(onPressed: () => {
              Navigator.pop(context, true)
            }, label: Text("Add"), icon: Icon(Icons.save),),),
            bottom: NonTappableTabBar(tabBar: TabBar(tabs: myTabs, isScrollable: true,),)
        ) : AppBar(
          title: Text("Add to Playlist"),
          bottom: TabBar(
            isScrollable: true,
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          physics: dataModel.selectedIndices.length > 0 ? NeverScrollableScrollPhysics() : null,
          children: [
            SongList(key: PageStorageKey("song_key"), playSongs: false,),
            ArtistList(key: PageStorageKey("artist_key"), goToDetails: false,),
            AlbumList(key: PageStorageKey("album_key"), goToDetails: false,),
          ],
        ),
      ),
    );
  }
}
