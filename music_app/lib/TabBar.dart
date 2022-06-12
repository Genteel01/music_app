import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'AlbumList.dart';
import 'AppBarTitle.dart';
import 'ArtistList.dart';
import 'CurrentlyPlayingBar.dart';
import 'DataModel.dart';
import 'PlaylistList.dart';
import 'Search.dart';
import 'SettingsPage.dart';
import 'SongList.dart';

class MyTabBar extends StatefulWidget {
  MyTabBar({Key? key}) : super(key: key);

  @override
  _MyTabBarState createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> with WidgetsBindingObserver {
  final List<Tab> myTabs = [
    Tab(child: Row(children: [Icon(Icons.library_music), Text(" Playlists")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.music_note), Text(" Tracks")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.person), Text(" Artists")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.album), Text(" Albums")],mainAxisAlignment: MainAxisAlignment.center,),),
  ];

  //Code to detect when you move between foreground and background
  AppLifecycleState? _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }

  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    if(_notification != null && _notification == AppLifecycleState.resumed)
    {
      dataModel.setUpNextIndexFromSongPath();
      _notification = null;
    }
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        bottomNavigationBar: CurrentlyPlayingBar(),
        appBar: dataModel.isSelecting() ? AppBar(
            title: SelectingAppBarTitle(),
            bottom: NonTappableTabBar(tabBar: TabBar(indicatorColor: Theme.of(context).primaryColor, tabs: myTabs, isScrollable: true,),)
        ) : AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Title
              Text("Music"),
              //Search Button
              Row(
                children: [
                  ElevatedButton.icon(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return SearchResults();
                        })).then((value) {
                      dataModel.searchResults.clear();
                    });
                  }, icon: Icon(Icons.search), label: Text("Search")),
                  //Menu
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.xSmall),
                    child: IconButton(icon: Icon(Icons.settings), color: dataModel.errorMessage == "" ? Colours.buttonIconColour : Colors.red, onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SettingsPage();
                          }));
                    },),
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: myTabs,
          ),
        ),
        body: dataModel.songs.length == 0 && dataModel.errorMessage != "" ? Padding(padding: const EdgeInsets.all(Dimens.xSmall), child: Text(dataModel.errorMessage),) : TabBarView(
          physics: dataModel.isSelecting() ? NeverScrollableScrollPhysics() : null,
          children: [
            PlaylistList(/*key: PageStorageKey("playlist_key"),*/),
            SongList(/*key: PageStorageKey("song_key"), */playSongs: true,),
            ArtistList(/*key: PageStorageKey("artist_key"), */goToDetails: true,),
            AlbumList(/*key: PageStorageKey("album_key"), */goToDetails: true,),
          ],
        ),
      ),
    );
  }
}

//Used top make the tab bar non tappable when you are selecting items in a list
class NonTappableTabBar extends StatelessWidget implements PreferredSizeWidget {
  const NonTappableTabBar({Key? key, required this.tabBar}) : super(key: key);
  final TabBar tabBar;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: tabBar);
  }

  @override Size get preferredSize => this.tabBar.preferredSize;
}