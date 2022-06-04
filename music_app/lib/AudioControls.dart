import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';

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