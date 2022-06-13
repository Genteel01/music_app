import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';


class PathsList extends StatefulWidget {
  const PathsList({Key? key}) : super(key: key);

  @override
  _PathsListState createState() => _PathsListState();
}

class _PathsListState extends State<PathsList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder:buildList
    );
  }
  Widget buildList(BuildContext context, DataModel dataModel, _){
    return ListView.builder(
      itemBuilder: (_, index) {
        if(index == 0)
        {
          return ListTile(
            leading: Icon(Icons.add),
            title: Text("Add New Location"),
            onTap: () async {
              await dataModel.getNewDirectory();
            },
          );
        }
        var path = dataModel.settings.directoryPaths[index - 1];

        return ListTile(
          title: Text(path),
          subtitle: Text("Hold to remove"),
          onLongPress: () async {
            await dataModel.removeDirectoryPath(path);
          },
        );
      },
      itemCount: dataModel.settings.directoryPaths.length + 1,
    );
  }
}