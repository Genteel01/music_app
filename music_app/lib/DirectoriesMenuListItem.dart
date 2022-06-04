import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'DirectoryPathsList.dart';

class DirectoriesMenuListItem extends StatefulWidget {
  const DirectoriesMenuListItem({
    Key? key,
  }) : super(key: key);

  @override
  _DirectoriesMenuListItemState createState() => _DirectoriesMenuListItemState();
}

class _DirectoriesMenuListItemState extends State<DirectoriesMenuListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildWidget
    );
  }

  Widget buildWidget(BuildContext context, DataModel dataModel, _) {
    return ListTile(
      title: Text("Music Directories"),
      subtitle: Text("Choose where to look for music on this device"),
      onTap: () => {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30))),
          builder: (BuildContext context) {
            return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: Container(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: PathsList(),
                ),
              ),
            );
          },
        ).then((value) {
          final snackBarMessage = SnackBar(
            content: Text("Song Locations Updated"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
          dataModel.fetch();
        })
      },
    );
  }
}