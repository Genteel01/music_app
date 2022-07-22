import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
      secondary: Colours.secondaryColour,
      surface: Colours.secondaryColour,
      background: Colours.backgroundColour,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.white,
      onError: Colors.black,
      brightness: Brightness.light);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colours.backgroundColour,
          systemNavigationBarIconBrightness: Brightness.light));
    }

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
              contentTextStyle: TextStyle(color: Colors.white),
              actionTextColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15)))
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: Colours.secondaryColour),
          elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: Colours.secondaryColour)),
          //dialogBackgroundColor: Color.fromARGB(255, 255, 240, 201),
          scaffoldBackgroundColor: Colours.backgroundColour,
          textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colours.secondaryColour, selectionColor: Colours.secondaryColour, cursorColor: Colours.secondaryColour),
          indicatorColor: Colours.primaryColour,
          checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected))
              return Colours.secondaryColour;
            return null;
          })),
          popupMenuTheme: Theme.of(context).popupMenuTheme.copyWith(color: Colours.secondaryColour),
          unselectedWidgetColor: Colours.secondaryColour,
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colours.mainTextColour,
            displayColor: Colours.mainTextColour,
          ),
          progressIndicatorTheme: Theme.of(context).progressIndicatorTheme.copyWith(color: Colours.secondaryColour),
          listTileTheme: Theme.of(context).listTileTheme.copyWith(selectedColor: Colours.secondaryColour),
          bottomSheetTheme: Theme.of(context).bottomSheetTheme.copyWith(backgroundColor: Colours.modalBackgroundColour),
          dialogTheme: Theme.of(context).dialogTheme.copyWith(backgroundColor: Colours.modalBackgroundColour,),
          sliderTheme: Theme.of(context).sliderTheme.copyWith(thumbColor: Colours.secondaryColour, activeTrackColor: Colours.secondaryColour),
          canvasColor: Colours.secondaryColour,
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: Colours.secondaryColour)),
          inputDecorationTheme: InputDecorationTheme(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colours.tertiaryColour)),
                                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colours.secondaryColour)),
                                                      hintStyle: TextStyle(color: Colours.searchHeaderTextColour))
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
