import 'package:flutter/material.dart';
import 'package:music_app/ArtistList.dart';
import 'package:music_app/Search.dart';
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
//TODO https://pub.dev/packages/assets_audio_player

//TODO feedback (adding to playlists, removing from playlists)
//TODO Marquee on overflowing text
//TODO adding to playlists from the playlist details screen
//TODO Scrollbars
//Part of the selection behaviour for playlist details screen
//TODO reordering playlists
//Both of these two can be in a hamburger menu
//TODO renaming playlists
//TODO deleting playlists from the playlist details screen

//TODO lock screen and notifications pulldown controls
//TODO settings page with adding and removing locations to look for music
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
        home: MyTabBar(),
        //home: MyHomePage(title: 'List Tutorial'),
      ),
    );
  }
}

class MyTabBar extends StatelessWidget {
  MyTabBar({Key? key}) : super(key: key);
//TODO work out how to retain the list positions when you change tabs
  final List<Tab> myTabs = [
    Tab(child: Row(children: [Icon(Icons.library_music), Text(" Playlists")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.music_note), Text(" Tracks")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.person), Text(" Artists")],mainAxisAlignment: MainAxisAlignment.center,),),
    Tab(child: Row(children: [Icon(Icons.album), Text(" Albums")],mainAxisAlignment: MainAxisAlignment.center,),),
  ];

  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildWidget
    );
  }
  Widget buildWidget(BuildContext context, DataModel dataModel, _){
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.library_music), onPressed: () async => {
          if(!dataModel.loading)
            {
              dataModel.directoryPaths = [],
              await dataModel.getNewDirectory(),
              await dataModel.fetch()
            }
        },
        ),
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
              }, icon: Icon(Icons.search), label: Text("Search"))
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          physics: dataModel.selectedIndices.length > 0 ? NeverScrollableScrollPhysics() : null,
          children: [
            PlaylistList(),
            SongList(),
            ArtistList(),
            AlbumList(),
          ],
        ),
      ),
    );
  }
}
class SelectingAppBarTitle extends StatefulWidget {
  const SelectingAppBarTitle({Key? key, this.album, this.artist, this.playlist}) : super(key: key);
  final Album? album;
  final Artist? artist;
  final Playlist? playlist;
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
          child: dataModel.loading || dataModel.settings.currentlyPlaying == null ? Row(children: [
            SizedBox(width: 65, height: 65,child: Image.asset("assets/images/music_note.jpg")), Padding(padding: const EdgeInsets.only(left: 8.0), child: Text("No Song Playing"),),
          ],) : Row(children: [
            SizedBox(width: 65, height: 65,child: dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!)!)),
            Padding(padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(width: 125,
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 30, child: Text(dataModel.settings.currentlyPlaying!.name, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                  Container(height: 30, child: Text(dataModel.settings.currentlyPlaying!.artist, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                ],),
              ),
            ),
            AudioControls(buttonSizes: 35,),
          ],
          ),
      ),onTap: dataModel.loading || dataModel.settings.currentlyPlaying == null ? () => {} : () => {
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
          child: SizedBox(width: widget.buttonSizes, height: widget.buttonSizes, child: FloatingActionButton(child: Icon(dataModel.audioPlayer.playing ? Icons.pause : Icons.play_arrow, color: Colors.grey[50],), heroTag: null, onPressed: () async => {
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
          SizedBox(height: 200, width: 200, child: dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!)!)),
          //Song name
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(dataModel.settings.currentlyPlaying!.name, overflow: TextOverflow.ellipsis,),
          ),
          //Song artist
          Text(dataModel.settings.currentlyPlaying!.artist, overflow: TextOverflow.ellipsis,),
          //Song album
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(dataModel.settings.currentlyPlaying!.album, overflow: TextOverflow.ellipsis,),
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
                dataModel.selectedItems.forEach((element) { oldSelections.add(element);}),
                dataModel.clearSelections(),
                oldSelectionType = dataModel.selectionType,
                dataModel.toggleSelection(dataModel.songs.indexOf(dataModel.settings.currentlyPlaying!), Song),
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
            stream: dataModel.audioPlayer.positionStream,
              builder: (context, snapshot) {
              if(snapshot.hasData)
                {
                  final position = snapshot.data;
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Current position
                      (position!.inSeconds % 60) < 10 ? Text(position.inMinutes.toString() + ":0" + (position.inSeconds % 60).toStringAsFixed(0)) :
                      Text(position.inMinutes.toString() + ":" + (position.inSeconds % 60).toStringAsFixed(0)),
                      //Position Slider
                      Slider(value: position.inSeconds.toDouble(), max: dataModel.audioPlayer.duration!.inSeconds.toDouble(), onChanged: (value) => {
                        dataModel.audioPlayer.seek(Duration(seconds: value.toInt()))
                      },),
                      //Duration
                      (dataModel.audioPlayer.duration!.inSeconds % 60) < 10 ? Text(dataModel.audioPlayer.duration!.inMinutes.toString() + ":0" + (dataModel.audioPlayer.duration!.inSeconds % 60).toStringAsFixed(0)) :
                      Text(dataModel.audioPlayer.duration!.inMinutes.toString() + ":" + (dataModel.audioPlayer.duration!.inSeconds % 60).toStringAsFixed(0)),
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
