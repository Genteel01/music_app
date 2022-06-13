import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'DataModel.dart';
import 'Song.dart';
import 'Values.dart';

class ArtistDetailsAlbumHeader extends StatelessWidget {
  const ArtistDetailsAlbumHeader({
    Key? key,
    required this.song,
    required this.index,
  }) : super(key: key);

  final Song song;
  final int index;

  @override
  Widget build(BuildContext context) {
    DataModel dataModel = Provider.of<DataModel>(context, listen:false);
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.small, bottom: Dimens.small, left: Dimens.small, right: Dimens.small),
      child: Row(
        children: [
          Hero(tag: index == 0 ? song.artist : "not_connected",
            child: SizedBox(width: Dimens.listItemSize, height: Dimens.listItemSize,
                child: dataModel.getAlbumArt(song) == "" ? Image.asset("assets/images/music_note.jpg") : Image.file(File(dataModel.getAlbumArt(song)))
            ),
          ),
          //OverflowMarqueeText(text: song.album, textSize: Dimens.listHeaderFontSize,)
            //AutoSizeText(song.album, maxLines: 1, minFontSize: 10)
          //SizedBox(width: 200, height: Dimens.listItemSize, child: Marquee(style: TextStyle(fontSize: 10), crossAxisAlignment: CrossAxisAlignment.start, text: song.album, velocity: 35, blankSpace: 32, fadingEdgeStartFraction: 0.1, fadingEdgeEndFraction: 0.1,))
          Expanded(child: Padding(
            padding: const EdgeInsets.only(left: Dimens.small),
            child: Text(song.albumName, style: TextStyle(fontSize: Dimens.listHeaderFontSize, color: Colours.searchHeaderTextColour), overflow: TextOverflow.ellipsis,),
          )),
        ],
      ),
    );
  }
}