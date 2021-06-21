import 'package:flutter/material.dart';
import 'package:music_app/ArtistList.dart';
import 'package:provider/provider.dart';

import 'Album.dart';
import 'AlbumList.dart';
import 'Artist.dart';
import 'DataModel.dart';
import 'PlaylistList.dart';
import 'SongList.dart';
//Saving/loading from json
//TODO https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
//TODO https://pub.dev/packages/path_provider/example

//TODO https://pub.dev/packages/audio_service
//TODO https://pub.dev/packages/just_audio
//TODO https://pub.dev/packages/assets_audio_player
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
        appBar: dataModel.selecting ? AppBar(
            title: SelectingAppBarTitle(),
            bottom: NonTappableTabBar(tabBar: TabBar(tabs: myTabs, isScrollable: true,),)
        ) : AppBar(
          title: Text("Music App"),
          bottom: TabBar(
            isScrollable: true,
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          physics: dataModel.selecting ? NeverScrollableScrollPhysics() : null,
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
  const SelectingAppBarTitle({Key? key, this.album, this.artist}) : super(key: key);
  final Album? album;
  final Artist? artist;
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
    return Row(
      children: [
        ElevatedButton(child: Text(dataModel.returnAllSelected(widget.album, widget.artist) ? "Clear" : "All"), onPressed: () => {
            dataModel.returnAllSelected(widget.album, widget.artist) ? dataModel.clearSelections() : dataModel.selectAll(widget.album, widget.artist)
        },),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(dataModel.selectedIndices.length.toString() + " Selected"),
        ),
      ],
    );
  }
}

class NonTappableTabBar extends StatelessWidget implements PreferredSizeWidget {
  const NonTappableTabBar({Key? key, required this.tabBar}) : super(key: key);
  final TabBar tabBar;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: tabBar);
  }

  @override Size get preferredSize => this.tabBar.preferredSize;
}

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
                height: 400,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 200, width: 200, child: dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!) == null ? Image.asset("assets/images/music_note.jpg") : Image.memory(dataModel.getAlbumArt(dataModel.settings.currentlyPlaying!)!)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AudioControls(buttonSizes: 60),
          ),
        ],
      ),
    );
  }
}
