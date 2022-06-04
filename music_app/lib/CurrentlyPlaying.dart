import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import 'AudioControls.dart';
import 'CurrentlyPlayingDetails.dart';
import 'DataModel.dart';

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
          SizedBox(width: 65, height: 65,child: Image.asset("assets/images/music_note.jpg")), Padding(padding: const EdgeInsets.only(left: 8.0), child: Text("No Song Playing"),),
        ],) : Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 65, height: 65,child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex])))),
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
              height: 450,
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