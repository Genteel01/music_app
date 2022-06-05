import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'AudioControls.dart';
import 'CurrentlyPlayingDetails.dart';
import 'DataModel.dart';
import 'OverflowMarqueeText.dart';

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
      child: Container(height: Dimens.currentlyPlayingBarSize, decoration: BoxDecoration(
          border: Border(top: BorderSide(width: Dimens.mediumBorderSize, color: Colours.currentlyPlayingBarBorderColour), bottom: BorderSide(width: Dimens.mediumBorderSize, color: Colours.currentlyPlayingBarBorderColour), left: BorderSide(width: Dimens.mediumBorderSize, color: Colours.currentlyPlayingBarBorderColour), right: BorderSide(width: Dimens.mediumBorderSize, color: Colours.currentlyPlayingBarBorderColour))),
        child: dataModel.loading || dataModel.settings.upNext.length == 0 ? Row(children: [
          SizedBox(width: Dimens.currentlyPlayingBarSize, height: Dimens.currentlyPlayingBarSize,child: Image.asset("assets/images/music_note.jpg")), Padding(padding: const EdgeInsets.only(left: Dimens.xSmall), child: Text("No Song Playing"),),
        ],) : Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: Dimens.currentlyPlayingBarSize, height: Dimens.currentlyPlayingBarSize,child: dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex]) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(dataModel.settings.upNext[dataModel.settings.playingIndex])))),
                  Expanded(
                    child: Padding(padding: const EdgeInsets.only(left: Dimens.xSmall, right: Dimens.xSmall, top: Dimens.xXSmall),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        OverflowMarqueeText(text: dataModel.settings.upNext[dataModel.settings.playingIndex].name, textSize: Dimens.currentlyPlayingSongFontSize,),
                        OverflowMarqueeText(text:dataModel.settings.upNext[dataModel.settings.playingIndex].artist, textSize: Dimens.currentlyPlayingArtistFontSize,)
                      ],),
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(right: Dimens.xSmall), child: AudioControls(buttonSizes: Dimens.currentlyPlayingBarButtonSize,),),
          ],
        ),
      ),onTap: dataModel.loading || dataModel.settings.upNext.length == 0 ? () => {} : () => {
      showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimens.currentlyPlayingModalBorderRadius))),
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery
                .of(context)
                .viewInsets,
            child: Container(
              height: Dimens.currentlyPlayingModalHeight,
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