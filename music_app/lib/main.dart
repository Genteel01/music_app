import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool fetched = false;
  //var files;
  List<File> files = [];
  @override
  void initState() {
    super.initState();
    getFiles();
  }
  void getFiles() async
  {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if(directoryPath != null)
      {
        var directoryMap = Directory(directoryPath).listSync(recursive: true);
        directoryMap.forEach((element) {
          if(element.path.endsWith("mp3"))
            {
              files.add(File(element.path));
            }
        });
      }
    //var fs = const LocalFileSystem();
    //Directory rootDirectory = fs.currentDirectory;
    /*directoryMap.forEach((element) {
          if(fs.isFileSync(element.path))
            {
              files!.add(element.path);
            }
        });*/
    //files = fs.file("/Download/Bowie-davidbowie.jpg");
    setState(() {
      fetched = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[if(!fetched) CircularProgressIndicator() else
            Expanded(
              child: Container(decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey), top: BorderSide(width: 0.5, color: Colors.grey),)),
                child: ListView.builder(
                    itemBuilder: (_, index) {
                      var file = files[index];
                      return Container(height: 70, decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey),)),
                        child: ListTile(
                          title: Text(file.path),
                          onTap: () => {

                          },
                        ),
                      );
                    },
                    itemCount: files.length
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
