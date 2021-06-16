import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'SongList.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataModel(),
      child: MaterialApp(
        title: "Music Player",
        home: MyTabBar(),
        //home: MyHomePage(title: 'List Tutorial'),
      ),
    );
  }
}

class MyTabBar extends StatelessWidget {
  MyTabBar({Key? key}) : super(key: key);

  final List<Tab> myTabs = [
    Tab(child: Row(children: [Icon(Icons.music_note), Text(" Tracks")],mainAxisAlignment: MainAxisAlignment.center,),),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.library_music), onPressed: () async => {
            if(!Provider.of<DataModel>(context, listen: false).loading)
              {
                await Provider.of<DataModel>(context, listen: false).fetch()
              }
        },
        ),
        appBar: AppBar(
          title: Text("Music App"),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: [
            SongList(),
          ],
        ),
      ),
    );
  }
}


