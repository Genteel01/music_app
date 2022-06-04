import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'TabBar.dart';
//Saving/loading from json
//https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  final ColorScheme crabColorScheme = ColorScheme(
      primary: Color.fromARGB(255, 221, 68, 68),
      primaryVariant: Color.fromARGB(255, 221, 68, 68),
      secondary: Color.fromARGB(255, 246, 160, 157),
      secondaryVariant: Color.fromARGB(255, 246, 160, 157),
      surface: Color.fromARGB(255, 246, 160, 157),
      background: Colors.white,
      error: Color.fromARGB(255, 255, 0, 0),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.black,
      brightness: Brightness.light);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataModel(),
      child: MaterialApp(
        theme: ThemeData(
          //primarySwatch: Colors.red,
          colorScheme: crabColorScheme,
          primaryColor: crabColorScheme.primary,
          //accentTextTheme: TextTheme(bodyText2: TextStyle(color: Colors.blue)),
          //primaryColor: Color.fromARGB(255, 246, 160, 157),
          snackBarTheme: SnackBarThemeData(
              backgroundColor: crabColorScheme.secondary,
              contentTextStyle: TextStyle(color: Colors.black),
              actionTextColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15)))
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: crabColorScheme.primary),
          //dialogBackgroundColor: Color.fromARGB(255, 255, 240, 201),
          scaffoldBackgroundColor: Colors.grey[50],
          textSelectionTheme: TextSelectionThemeData(selectionHandleColor: crabColorScheme.secondary, selectionColor: crabColorScheme.secondary, cursorColor: crabColorScheme.secondary),
        ),
        title: "Music Player",
        home: AudioServiceWidget(child: MyTabBar()),
        //home: MyHomePage(title: 'List Tutorial'),
      ),
    );
  }
}
