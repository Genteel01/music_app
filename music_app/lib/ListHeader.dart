import 'package:flutter/material.dart';

import 'Values.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.small, bottom: Dimens.small, left: Dimens.small, right: Dimens.small),
      child: Text(text, style: TextStyle(fontSize: Dimens.listHeaderFontSize, color: Colours.searchHeaderTextColour),),
    );
  }
}