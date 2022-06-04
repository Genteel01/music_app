import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'DirectoriesMenuListItem.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, DataModel dataModel, _) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: dataModel.loading ? Center(child: CircularProgressIndicator()) : Column(
            children: <Widget>[
              Expanded(
                child: Container(decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                    child: ListView(
                      children: [
                        if(dataModel.errorMessage != "") Padding(padding: const EdgeInsets.all(Dimens.xSmall), child: Text(dataModel.errorMessage),),
                        DirectoriesMenuListItem(),
                      ],
                    )
                ),
              )
            ]
        )
    );
  }
}