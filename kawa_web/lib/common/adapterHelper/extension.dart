part of "responsive_sizer.dart";

extension DeviceExt on num {
  //  *****************  Absolute length units *****************************************
  // https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Values_and_units

  /// The respective value in centimeters
  double get cm => this * 37.8;

  /// The respective value millimeters
  double get mm => this * 3.78;

  /// The respective value in quarter-millimeters
  double get Q => this * 0.945;

  /// The respective value in inches
  double get inches => this * 96;

  /// The respective value in picas (1/6th of 1 inch)
  double get pc => this * 16;

  /// The respective value in points (1/72th of 1 inch)
  double get pt => this * inches / 72;

  /// The respective value in pixels (default)
  double get px => toDouble();

  //  *****************  Relative length units *****************************************
  // https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/Values_and_units

  // TODO Recursive units need to be implemented
  /*double get em => ;
  double get ex => ;
  double get ch => ;
  double get rem => ;
  double get lh => ;*/

  /// Respective percentage of the viewport's smaller dimension.
  double get vmin => this * min(Device.height, Device.width) / 100;

  /// Respective percentage of the viewport's larger dimension.
  double get vmax => this * max(Device.height, Device.width) / 100;

  /// Calculates the height depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's height
  double get h => this * Device.height / 100;

  /// Calculates the height depending on the current device's screen size
  ///
  /// Eg: 20.hS(s) -> will take 20% of the screen's height of the given size
  double hS(Size s) =>
      this *
      ((s.height.isInfinite || s.height.isNaN || s.height.isNegative)
          ? Device.height
          : s.height) /
      100;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's width
  double get w => this * Device.width / 100;

  /// Calculates the width depending on the current device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's width of the given size
  double wS(Size s) =>
      this *
      ((s.width.isInfinite || s.width.isNaN || s.width.isNegative)
          ? Device.width
          : s.width) /
      100;

  /// Eg: 20.h -> will take 20% of the screen's height
  double get h_2 =>
      (Device.height > 850 ? this - 2 : this) * Device.height / 100;

  double get h2P =>
      (Device.height > 850 ? this + 2 : this) * Device.height / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's pixel
  /// density and aspect ratio
  double get sp =>
      this *
      (((h + w) + (Device.pixelRatio * Device.aspectRatio)) / 2.08) /
      100;

  /// Calculates the sp (Scalable Pixel) depending on the current device's screen pixel
  /// density and aspect ratio
  double spS(Size s) =>
      this *
      (((hS(s) + wS(s)) + (Device.pixelRatio * Device.aspectRatio)) / 2.08) /
      100;

  /// Calculates the material dp (Pixel Density)
  /// (https://material.io/design/layout/pixel-density.html#pixel-density-on-android))
  double get dp => this * (w * 160) / Device.pixelRatio;

  /// Calculates the sp (Scalable Pixel) based on Issue #27
  double get spa =>
      this * (((h + w) + (240 * Device.aspectRatio)) / 2.08) / 100;
}
