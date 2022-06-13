import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'TabBar.dart';
import 'Values.dart';
//Saving/loading from json
//https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc


void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ColorScheme crabColorScheme = ColorScheme(
      primary: Colours.primaryColour,
      primaryVariant: Colours.primaryColour,
      secondary: Colours.secondaryColour,
      secondaryVariant: Colours.secondaryColour,
      surface: Colours.secondaryColour,
      background: Colours.backgroundColour,
      error: Colors.red,
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
          snackBarTheme: SnackBarThemeData(
              backgroundColor: crabColorScheme.secondary,
              contentTextStyle: TextStyle(color: Colors.black),
              actionTextColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15)))
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: crabColorScheme.primary),
          //dialogBackgroundColor: Color.fromARGB(255, 255, 240, 201),
          scaffoldBackgroundColor: Colours.backgroundColour,
          textSelectionTheme: TextSelectionThemeData(selectionHandleColor: crabColorScheme.secondary, selectionColor: crabColorScheme.secondary, cursorColor: crabColorScheme.secondary),
          indicatorColor: crabColorScheme.primary,
          checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected))
              return crabColorScheme.primary;
            return null;
          })),
        ),
        title: "Music Player",
        home: MyTabBar(),
        /*builder: (context, child) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(child: child!),
                CurrentlyPlayingBar()
              ],
            ),
          );
        },*/
      ),
    );
  }
}
