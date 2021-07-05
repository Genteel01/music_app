import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_app/ArtistList.dart';
import 'package:music_app/Search.dart';
import 'package:music_app/Settings.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumList.dart';
import 'Artist.dart';
import 'DataModel.dart';
import 'Playlist.dart';
import 'PlaylistList.dart';
import 'Song.dart';
import 'SongList.dart';
//Saving/loading from json
//TODO https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
//TODO https://pub.dev/packages/path_provider/example

//TODO https://pub.dev/packages/audio_service
//TODO https://pub.dev/packages/just_audio

//TODO feedback (adding to playlists, removing from playlists, creating playlists, deleting playlists, adding file path, removing file path)
void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataModel(),
      child: MaterialApp(
        title: "Music Player",
        home: AudioServiceWidget(child: MyTabBar()),
        //home: MyHomePage(title: 'List Tutorial'),
      ),
    );
  }
}

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

  final TextEditingController searchController = TextEditingController();
  //Code to detect when you move between foreground and background
  AppLifecycleState? _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
    switch (_notification) {
      case null:
        print("notification is null");
        break;
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
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
        appBar: dataModel.selectedIndices.length > 0 ? AppBar(
            title: SelectingAppBarTitle(),
            bottom: NonTappableTabBar(tabBar: TabBar(tabs: myTabs, isScrollable: true,),)
        ) : AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Title
              Text("Music"),
              //Search Button
              Row(
                children: [
                  ElevatedButton.icon(onPressed: () => {
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30))),
                      builder: (BuildContext context) {
                        return Padding(
                          padding: MediaQuery
                              .of(context)
                              .viewInsets,
                          child: Container(
                            height: 500,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(controller: searchController, decoration: InputDecoration(hintText: "Search"), onChanged: (s) => {
                                    dataModel.getSearchResults(s)
                                  },)
                                ),
                                SearchResults(),
                              ],
                            ),
                          ),
                        );
                      },
                    ).then((value) => {
                      searchController.text = "",
                      dataModel.searchResults.clear()
                    })
                  }, icon: Icon(Icons.search), label: Text("Search")),
                  //Menu
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(icon: Icon(Icons.settings), color: dataModel.errorMessage == "" ? Colors.grey[50] : Colors.red, onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SettingsPage();
                          }))
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
        body: dataModel.songs.length == 0 && dataModel.errorMessage != "" ? Padding(padding: const EdgeInsets.all(8.0), child: Text(dataModel.errorMessage),) : TabBarView(
          physics: dataModel.selectedIndices.length > 0 ? NeverScrollableScrollPhysics() : null,
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
class SelectingAppBarTitle extends StatefulWidget {
  const SelectingAppBarTitle({Key? key, this.album, this.artist, this.playlist, this.rightButtonReplacement}) : super(key: key);
  final Album? album;
  final Artist? artist;
  final Playlist? playlist;
  final Widget? rightButtonReplacement;
  @override
  _SelectingAppBarTitleState createState() => _SelectingAppBarTitleState();
}

class _SelectingAppBarTitleState extends State<SelectingAppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton(child: Text(dataModel.returnAllSelected(widget.album, widget.artist, widget.playlist) ? "Clear" : "All"), onPressed: () => {
                dataModel.returnAllSelected(widget.album, widget.artist, widget.playlist) ? dataModel.clearSelections() : dataModel.selectAll(widget.album, widget.artist, widget.playlist)
            },),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(dataModel.selectedIndices.length.toString() + " Selected"),
            ),
          ],
        ),
        widget.rightButtonReplacement != null ? widget.rightButtonReplacement! :
        ElevatedButton(child: Text(dataModel.selectionType == Playlist || widget.playlist != null ? "Remove" : "Add To"), onPressed: () => {
          if(dataModel.selectionType == Playlist)
            {
              dataModel.deletePlaylists()
            }
          else if(widget.playlist != null)
            {
              dataModel.removeFromPlaylist(widget.playlist!)
            }
          else
            {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30))),
                builder: (BuildContext context) {
                  return Padding(
                    padding: MediaQuery
                        .of(context)
                        .viewInsets,
                    child: Container(
                      height: 400,
                      //color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Flex(direction: Axis.vertical, children: [
                          PlaylistListBuilder(addingToPlaylist: true,)
                        ]),
                      ),
                    ),
                  );
                },
              )
            }
        },),
      ],
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
//The bar that appears at the bottom of the screen giving basic details about the currently playing song and playback controls.
class CurrentlyPlayingBar extends StatefulWidget {
  const CurrentlyPlayingBar({Key? key}) : super(key: key);

  @override
  _CurrentlyPlayingBarState createState() => _CurrentlyPlayingBarState();
}

class _CurrentlyPlayingBarState extends State<CurrentlyPlayingBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return InkWell(
      child: Container(height: 65, decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 0.5, color: Colors.black), bottom: BorderSide(width: 0.5, color: Colors.black), left: BorderSide(width: 0.5, color: Colors.black), right: BorderSide(width: 0.5, color: Colors.black))),
          child: dataModel.loading || dataModel.settings.upNext.length == 0 ? Row(children: [
            SizedBox(width: 65, height: 65,child: Hero(tag: "currently_playing_widget", child: Image.asset("assets/images/music_note.jpg"))), Padding(padding: const EdgeInsets.only(left: 8.0), child: Text("No Song Playing"),),
          ],) : Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 65, height: 65,child: Hero(tag: "currently_playing_widget", child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex])!))),
                    Expanded(
                      child: Padding(padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: AutoSizeText(dataModel.settings.upNext[dataModel.settings.playingIndex].name, maxLines: 1, style: TextStyle(fontSize: 16), minFontSize: 16, overflowReplacement:
                          Marquee(style: TextStyle(fontSize: 16), crossAxisAlignment: CrossAxisAlignment.start, text: dataModel.settings.upNext[dataModel.settings.playingIndex].name, velocity: 35, blankSpace: 32, fadingEdgeStartFraction: 0.1, fadingEdgeEndFraction: 0.1,),)),
                          Expanded(child: AutoSizeText(dataModel.settings.upNext[dataModel.settings.playingIndex].artist, maxLines: 1, overflowReplacement:
                          Marquee(crossAxisAlignment: CrossAxisAlignment.start, text: dataModel.settings.upNext[dataModel.settings.playingIndex].artist, velocity: 35, blankSpace: 32, fadingEdgeStartFraction: 0.1, fadingEdgeEndFraction: 0.1,),)),
                        ],),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.only(right: 8.0), child: AudioControls(buttonSizes: 35,),),
          ],
          ),
      ),onTap: dataModel.loading || dataModel.settings.upNext.length == 0 ? () => {} : () => {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
              top: Radius.circular(30))),
          builder: (BuildContext context) {
            return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: Container(
                height: 430,
                //color: Colors.amber,
                child: PlayingSongDetails(),
              ),
            );
          },
        )
    },
    );
  }
}
//Controls to play, pause, go back, and go forwards. Is passed in a size for the buttons so it can be used in several places.
class AudioControls extends StatefulWidget {
  const AudioControls({Key? key, required this.buttonSizes}) : super(key: key);
  final double buttonSizes;
  @override
  _AudioControlsState createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return Row(mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: widget.buttonSizes, height: widget.buttonSizes, child: FloatingActionButton(child: Icon(Icons.skip_previous, color: Colors.grey[50],), heroTag: null, onPressed: () => {
          dataModel.previousButton(),
        },)),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: SizedBox(width: widget.buttonSizes, height: widget.buttonSizes, child: FloatingActionButton(child: Icon(dataModel.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.grey[50],), heroTag: null, onPressed: () async => {
            dataModel.playButton(),
          },)),
        ),
        SizedBox(width: widget.buttonSizes, height: widget.buttonSizes, child: FloatingActionButton(child: Icon(Icons.skip_next, color: Colors.grey[50],), heroTag: null, onPressed: () => {
          dataModel.nextButton()
        },)),
      ],
    );
  }
}
//Shows the details of the currently playing song. Appears in the bottom modal that appears when tapping the currently playing bar.
class PlayingSongDetails extends StatefulWidget {
  const PlayingSongDetails({Key? key}) : super(key: key);

  @override
  _PlayingSongDetailsState createState() => _PlayingSongDetailsState();
}

class _PlayingSongDetailsState extends State<PlayingSongDetails> {
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }

  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    List<int> oldSelections = [];
    Type oldSelectionType = Song;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Album art image
          SizedBox(height: 200, width: 200, child: Hero(tag: "currently_playing_widget", child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex])!))),
          //Song name
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(dataModel.settings.upNext[dataModel.settings.playingIndex].name, overflow: TextOverflow.ellipsis,),
          ),
          //Song artist
          Text(dataModel.settings.upNext[dataModel.settings.playingIndex].artist, overflow: TextOverflow.ellipsis,),
          //Song album
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(dataModel.settings.upNext[dataModel.settings.playingIndex].album, overflow: TextOverflow.ellipsis,),
          ),
          //shuffle, loop, and add to playlist row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 30, height: 30, child: FloatingActionButton(backgroundColor: dataModel.settings.shuffle ? Theme.of(context).primaryColor : Colors.grey, child: Icon( Icons.shuffle, color: Colors.grey[50],), heroTag: null, onPressed: () => {
                dataModel.toggleShuffle(),
              },)),
              //Loop button
              SizedBox(width: 30, height: 30, child: FloatingActionButton(child: Icon(dataModel.settings.loop == LoopType.singleSong ? Icons.repeat_one : (dataModel.settings.loop == LoopType.loop ? Icons.repeat : Icons.arrow_right_alt)
                , color: Colors.grey[50],), heroTag: null, onPressed: () => {
                dataModel.toggleLoop(),
              },)),
              SizedBox(width: 30, height: 30, child: FloatingActionButton(child: Icon(Icons.playlist_add), onPressed: () => {
                dataModel.selectedIndices.forEach((element) { oldSelections.add(element);}),
                dataModel.clearSelections(),
                oldSelectionType = dataModel.selectionType,
                dataModel.toggleSelection(dataModel.songs.indexOf(dataModel.settings.upNext[dataModel.settings.playingIndex]), Song),
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30))),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: MediaQuery
                            .of(context)
                            .viewInsets,
                        child: Container(
                          height: 400,
                          //color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Flex(direction: Axis.vertical, children: [PlaylistListBuilder(addingToPlaylist: true,)]),
                          ),
                        ),
                      );
                    },
                  ).then((value) => {dataModel.clearSelections(), oldSelections.forEach((element) {dataModel.toggleSelection(element, oldSelectionType);})})
                },),
              ),
            ],
          ),
          //Seekbar
          StreamBuilder<Duration> (
            stream: AudioService.positionStream,
              builder: (context, snapshot) {
              if(snapshot.hasData)
                {
                  final position = snapshot.data;
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.min,
                    children: [
                      //Current position
                      (position!.inSeconds % 60) < 10 ? Text(position.inMinutes.toString() + ":0" + (position.inSeconds % 60).toStringAsFixed(0)) :
                      Text(position.inMinutes.toString() + ":" + (position.inSeconds % 60).toStringAsFixed(0)),
                      //Position Slider
                      Slider(value: position.inSeconds.toDouble(), max: Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inSeconds.toDouble(), onChanged: (value) => {
                        AudioService.seekTo(Duration(seconds: value.toInt()))
                      },),
                      //Duration
                      (Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inSeconds % 60) < 10 ? Text(Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inMinutes.toString() + ":0" + (Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inSeconds % 60).toStringAsFixed(0)) :
                      Text(Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inMinutes.toString() + ":" + (Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration).inSeconds % 60).toStringAsFixed(0)),
                    ],
                  );
                }
              return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Current position
                  Text("0:00"),
                  //Position Slider
                  Slider(value: 0, max: 1, onChanged: (value) => {},),
                  //Duration
                  Text("0:00"),
                ],
              );
              }
          ),
          //Audio Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AudioControls(buttonSizes: 55),
          ),
        ],
      ),
    );
  }
}
