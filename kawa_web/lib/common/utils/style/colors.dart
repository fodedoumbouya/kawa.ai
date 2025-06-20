import 'package:flutter/material.dart';

class KColors {
  static const bcGrey = Colors.grey;
  static MaterialColor bc = getMaterialColor(Color.fromRGBO(250, 250, 250, 1));
  static MaterialColor bcDark = getMaterialColor(Color.fromRGBO(33, 33, 33, 1));
  static const bpLightWhite = Color.fromRGBO(243, 243, 243, 1);
  static const bpWhite = Colors.white;
  static const bpLightBlack = Colors.black;
  static const bcGreen = Colors.green;
  static const bcRed = Colors.red;
  static const bcBlack = Color.fromARGB(255, 28, 28, 30); //Colors.black;
  static const bcYellow = Color.fromARGB(255, 245, 157, 25);
  static const bcBlue = Color.fromARGB(255, 0, 122, 255); // Colors.blue;
  // Colors.yellow;
  static const bcDarkPurple = Color.fromARGB(209, 1, 5, 48);
  static const bcLightPurple = Color.fromARGB(209, 137, 137, 231);

  static MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }
}
