import 'package:flutter/material.dart';

/// this function is used to resize the root app when the screen size changes
/// usecase: when the screen size changes, the root app should be resized
/// the app size can be reduce/ increase on the ipad so the app should be resized
/// the app size can be reduce/ increase on the web so the app should be resized
class ResizeRootApp {
  static final ResizeRootApp instance = ResizeRootApp._internal();

  factory ResizeRootApp() {
    return instance;
  }

  ResizeRootApp._internal();

  double? width;
  double? height;
  GlobalKey globalKey = GlobalKey();

  resizeUpdate(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width1 = mediaQuery.size.width;
    final height1 = mediaQuery.size.height;
    if (width1 != width || height1 != height) {
      width = width1;
      height = height1;
      globalKey = GlobalKey();
      // print("s: update width: $width height: $height");
    }
  }
}
