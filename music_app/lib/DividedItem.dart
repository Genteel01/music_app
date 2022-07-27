import 'package:flutter/material.dart';

class DividedItem extends StatelessWidget {
  const DividedItem({Key? key, required this.child}) : super(key: key);

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      child,
      Divider()
    ],);
  }
}
