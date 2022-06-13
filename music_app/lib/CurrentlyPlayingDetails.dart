import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
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

    Duration currentSongDuration = Duration(milliseconds: dataModel.settings.upNext[dataModel.settings.playingIndex].duration);
    return Padding(
      padding: const EdgeInsets.all(Dimens.xSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Album art image
          SizedBox(height: Dimens.currentlyPlayingModalImageSize, width: Dimens.currentlyPlayingModalImageSize, child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex])))),
          //Song name
          Padding(
            padding: const EdgeInsets.only(top: Dimens.xXSmall, bottom: Dimens.xXSmall),
            child: Text(dataModel.settings.upNext[dataModel.settings.playingIndex].name, overflow: TextOverflow.ellipsis,),
          ),
          //Song artist
          Text(dataModel.settings.upNext[dataModel.settings.playingIndex].artist, overflow: TextOverflow.ellipsis,),
          //Song album
          Padding(
            padding: const EdgeInsets.only(top: Dimens.xXSmall, bottom: Dimens.xXSmall),
            child: Text(dataModel.settings.upNext[dataModel.settings.playingIndex].albumName, overflow: TextOverflow.ellipsis,),
          ),
          //shuffle, loop, and add to playlist row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: Dimens.currentlyPlayingModalButtonSize, height: Dimens.currentlyPlayingModalButtonSize, child: FloatingActionButton(backgroundColor: dataModel.settings.shuffle ? Theme.of(context).primaryColor : Colours.disabledButtonColour, child: Icon( Icons.shuffle, color: Colours.buttonIconColour,), heroTag: null, onPressed: () {
                dataModel.toggleShuffle();
              },)),
              //Loop button
              SizedBox(width: Dimens.currentlyPlayingModalButtonSize, height: Dimens.currentlyPlayingModalButtonSize, child: FloatingActionButton(child: Icon(dataModel.settings.loop == LoopType.singleSong ? Icons.repeat_one : (dataModel.settings.loop == LoopType.loop ? Icons.repeat : Icons.arrow_right_alt)
                , color: Colors.grey[50],), heroTag: null, onPressed: () {
                dataModel.toggleLoop();
              },)),
              SizedBox(width: Dimens.currentlyPlayingModalButtonSize, height: Dimens.currentlyPlayingModalButtonSize, child: FloatingActionButton(child: Icon(Icons.playlist_add), onPressed: () {
                dataModel.selectedIndices.forEach((element) { oldSelections.add(element);});
                dataModel.clearSelections();
                oldSelectionType = dataModel.selectionType;
                dataModel.toggleSelection(dataModel.songs.indexOf(dataModel.settings.upNext[dataModel.settings.playingIndex]), Song);
                showModalBottomSheet<void>(
                  isScrollControlled: true,
                  context: context,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Dimens.playlistModalBorderRadius))),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: MediaQuery
                          .of(context)
                          .viewInsets,
                      child: Container(
                        height: Dimens.playlistModalHeight,
                        //color: Colors.amber,
                        child: Flex(direction: Axis.vertical, children: [PlaylistListBuilder(addingToPlaylist: true,)]),
                      ),
                    );
                  },
                ).then((value) {dataModel.clearSelections(); oldSelections.forEach((element) {dataModel.toggleSelection(element, oldSelectionType);});});
              },),
              ),
            ],
          ),
          //Seekbar
          StreamBuilder<Duration> (
              //Note still using deprecated `positionStream` instead of `position` because with `position` it doesn't get the position while paused
              stream: AudioService.positionStream,
              builder: (context, snapshot) {
                if(snapshot.hasData)
                {
                  final position = snapshot.data;

                  if(!dataModel.isSeeking) dataModel.setPosition(position!);

                  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.min,
                    children: [
                      //Current position text
                      Text(Strings.timeFormat(dataModel.currentPosition)),
                      //Position Slider
                      Slider(value: dataModel.currentPosition.inMilliseconds.toDouble(), max: dataModel.settings.upNext[dataModel.settings.playingIndex].duration.toDouble(),
                        onChanged: (value) {
                        dataModel.setPosition(Duration(milliseconds: value.toInt()));
                      },
                        onChangeStart: (value) async {
                          await dataModel.startSeek();
                          dataModel.seekbarIsPushed = true;
                      },
                      onChangeEnd: (value) {
                        dataModel.seekbarIsPushed = false;
                        //Workaround for onChangeStart and onChangeEnd firing twice
                        Future.delayed(const Duration(milliseconds: 200), () async {
                          if(!dataModel.seekbarIsPushed)
                            {
                              await dataModel.stopSeek(Duration(milliseconds: value.toInt()));
                            }
                        });
                      },),
                      //Duration text
                      Text(Strings.timeFormat(currentSongDuration)),
                    ],
                  );
                }
                return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Current position
                    Text("0:00"),
                    //Position Slider
                    Slider(value: 0, max: 1, onChanged: (value) {},),
                    //Duration
                    Text("0:00"),
                  ],
                );
              }
          ),
          //Audio Controls
          Padding(
            padding: const EdgeInsets.all(Dimens.xXSmall),
            child: AudioControls(buttonSizes: Dimens.currentlyPlayingModalControlsSize),
          ),
        ],
      ),
    );
  }
}
