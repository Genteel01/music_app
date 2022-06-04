import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AudioControls.dart';
import 'DataModel.dart';
import 'Looping.dart';
import 'PlaylistList.dart';
import 'Song.dart';

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
          SizedBox(height: 200, width: 200, child: Hero(tag: "currently_playing_widget", child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]))))),
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
                      top: Radius.circular(0))),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: MediaQuery
                          .of(context)
                          .viewInsets,
                      child: Container(
                        height: 400,
                        //color: Colors.amber,
                        child: Flex(direction: Axis.vertical, children: [PlaylistListBuilder(addingToPlaylist: true,)]),
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
