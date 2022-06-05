import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class OverflowMarqueeText extends StatelessWidget {
  const OverflowMarqueeText({
    Key? key,
    required this.text,
    required this.textSize,
  }) : super(key: key);

  final String text;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: AutoSizeText(text, maxLines: 1, style: TextStyle(fontSize: textSize), minFontSize: textSize, overflowReplacement:
    Marquee(style: TextStyle(fontSize: textSize), crossAxisAlignment: CrossAxisAlignment.start, text: text, velocity: 35, blankSpace: 32, fadingEdgeStartFraction: 0.1, fadingEdgeEndFraction: 0.1,),));
  }
}