import 'dart:ui';

import 'package:flutter/material.dart';

class Dimens{
  static const double tiny = 2;
  static const double xXSmall = 4;
  static const double xSmall = 8;
  static const double small = 16;
  static const double medium = 24;
  static const double large = 32;
  static const double xLarge = 48;
  static const double xXLarge = 64;

  static const double listItemSize = 75;

  static const double playlistModalHeight = 400;
  static const double playlistModalBorderRadius = 0;

  static const double directoryPickerModalHeight = 400;
  static const double directoryPickerModalBorderRadius = 30;

  static const double thinBorderSize = 0.25;
  static const double mediumBorderSize = 0.5;

  static const double listHeaderFontSize = 18;
  static const double searchTextFieldWidth = 200;

  static const double currentlyPlayingBarSize = 65;
  static const double currentlyPlayingSongFontSize = 16;
  static const double currentlyPlayingArtistFontSize = 14;
  static const double currentlyPlayingBarButtonSize = 35;

  static const double currentlyPlayingModalHeight = 450;
  static const double currentlyPlayingModalBorderRadius = 30;
  static const double currentlyPlayingModalImageSize = 200;
  static const double currentlyPlayingModalButtonSize = 30;
  static const double currentlyPlayingModalControlsSize = 55;

}

class Colours{
  static const Color primaryColour = Color.fromARGB(255, 0, 0, 64);
  static const Color secondaryColour = Color.fromARGB(255, 64, 64, 128);
  static const Color tertiaryColour = Color.fromARGB(255, 96, 96, 192);
  static const Color backgroundColour = Color.fromARGB(255, 16, 16, 16);
  static const Color modalBackgroundColour = Color.fromARGB(255, 32, 32, 32);
  static const Color mainTextColour = Color.fromARGB(255, 255, 255, 255);
  static const Color searchHeaderTextColour = Color.fromARGB(255, 165, 165, 165);
  static const Color buttonIconColour = Color.fromARGB(255, 250, 250, 250);
  static const Color disabledButtonColour = Color.fromARGB(255, 128, 128, 128);
  static const Color redDisabledButtonColour = Color.fromARGB(255, 90, 0, 0);
  static const Color deepRed = Color.fromARGB(255, 156, 30, 30);
  static const Color listDividerColour = Color.fromARGB(255, 158, 158, 158);
  static const Color currentlyPlayingBarBorderColour = Color.fromARGB(255, 0, 0, 0);
}

class Strings{
  static String timeFormat(Duration time)
  {
    int currentHours = time.inHours;
    int currentMinutes = time.inMinutes % 60;
    int currentSeconds = time.inSeconds % 60;
    String timeString = "";
    if(currentHours > 0) timeString += currentHours.toString() + ":";
    if(currentHours > 0 && currentMinutes < 10)
    {
      timeString += "0" + currentMinutes.toString();
    }
    else
      {
        timeString += currentMinutes.toString();
      }
    timeString += ":";
    if(currentSeconds < 10)
    {
      timeString += "0" + currentSeconds.toString();
    }
    else
    {
      timeString += currentSeconds.toString();
    }
    return timeString;
  }
}