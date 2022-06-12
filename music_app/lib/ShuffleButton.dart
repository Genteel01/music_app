import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';

import 'DataModel.dart';
import 'Song.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    Key? key, required this.dataModel, required this.futureSongs
  }) : super(key: key);
  final DataModel dataModel;
  final List<Song> futureSongs;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.xSmall),
      child: Align(alignment: Alignment.centerLeft,
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(onPressed: () {dataModel.playRandomSong(futureSongs);}, icon: Icon(Icons.shuffle), label: Text(futureSongs.length == 1 ? "Shuffle ${futureSongs.length} track" : "Shuffle ${futureSongs.length} tracks" )),
          ],
        ),
      ),
    );
  }
}