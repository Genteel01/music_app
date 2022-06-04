import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AlbumList.dart';
import 'AppBarTitle.dart';
import 'ArtistList.dart';
import 'DataModel.dart';
import 'SongList.dart';
import 'TabBar.dart';

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
            SongList(/*key: PageStorageKey("song_key"), */playSongs: false,),
            ArtistList(/*key: PageStorageKey("artist_key"), */goToDetails: false,),
            AlbumList(/*key: PageStorageKey("album_key"), */goToDetails: false,),
          ],
        ),
      ),
    );
  }
}
