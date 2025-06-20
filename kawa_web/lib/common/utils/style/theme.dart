import 'package:flutter/material.dart';

import 'colors.dart';

class KTheme {
  KTheme._();

  static dartTheme() {
    return ThemeData(
      primaryColor: KColors.bcBlack,
      scaffoldBackgroundColor: KColors.bcDark,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: KColors.bc,
        selectionColor: KColors.bc.withValues(alpha: 0.2),
        selectionHandleColor: KColors.bc.withValues(alpha: 0.2),
      ),
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: KColors.bcDark).copyWith(
        primaryContainer: Colors.white,
        primary: KColors.bcDark, // background color blue of the app
        shadow: KColors.bpWhite, //bcBlack,
        brightness: Brightness.dark,
        onPrimary: KColors.bpLightBlack,
        scrim: KColors.bpLightWhite, // picker time focused color
        onPrimaryContainer: KColors.bcDark, // picker time focused text color
        surfaceContainerHighest:
            KColors.bpLightBlack, // picker time unfocused color
        onSurface: KColors.bpLightWhite, // picker time unfocused text color
        surface: KColors.bpLightBlack, // picker time backgroud color
        onSurfaceVariant: KColors.bpLightWhite, // picker time header color

        secondaryContainer: KColors.bcGrey, // for upgrade button
        onSecondaryContainer: KColors.bcLightPurple,
      ),
      dialogTheme: DialogThemeData(backgroundColor: KColors.bcBlack),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: KColors.bc,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: KColors.bcDark,
        selectionColor: KColors.bcDark.withValues(alpha: 0.2),
        selectionHandleColor: KColors.bcDark.withValues(alpha: 0.2),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: KColors.bc).copyWith(
        primaryContainer: KColors.bpLightBlack,
        primary: KColors.bc, // background color blue of the app
        shadow: KColors.bcBlack,
        brightness: Brightness.light,
        onPrimary: KColors.bpLightWhite,

        scrim: KColors.bc, // picker time focused color
        onPrimaryContainer:
            KColors.bpLightWhite, // picker time focused text color
        surfaceContainerHighest:
            KColors.bpLightWhite, // picker time unfocused color
        onSurface: KColors.bpLightBlack, // picker time unfocused text color
        surface: KColors.bpLightWhite, // picker time backgroud color
        onSurfaceVariant: KColors.bpLightBlack, // picker time header color
        secondaryContainer: KColors.bcGrey, // for upgrade button
        onSecondaryContainer: KColors.bcDarkPurple,
      ),
      dialogTheme: DialogThemeData(backgroundColor: KColors.bpWhite),
    );
  }
}
