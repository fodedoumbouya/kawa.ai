part of 'custom.dart';

enum TextType { autoSize, normal, selectable }

class CustomTextWidget extends ConsumerWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? size;
  final TextAlign? textAlign;
  final bool withOverflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final Paint? foreground;
  final String? fontFamily;
  final FontStyle? fontStyle;
  final List<Shadow>? shadows;
  final double? minFontSize;
  final double? maxFontSize;
  // final bool isAutoSize;
  final TextType textType;
  final bool withFactor;
  const CustomTextWidget(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.size,
    this.textAlign,
    this.withOverflow = true,
    this.maxLines,
    this.decoration,
    this.foreground,
    this.fontFamily = 'Roboto',
    this.fontStyle,
    this.shadows,
    this.minFontSize,
    this.maxFontSize,
    this.textType = TextType.autoSize,
    this.withFactor = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextOverflow? overflow = withOverflow ? TextOverflow.ellipsis : null;
    Widget w;
    switch (textType) {
      case TextType.autoSize:
        w = AutoSizeText(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          minFontSize: minFontSize ?? 12,
          maxFontSize: maxFontSize ?? double.infinity,
          overflow: overflow,
          style: GoogleFonts.openSans(
            color: color,
            fontWeight: fontWeight,
            fontSize: size ?? 12.sp,
            decoration: decoration,
            fontStyle: fontStyle,
            foreground: foreground,
            shadows: shadows,
          ),
        );
      case TextType.normal:
        w = Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: GoogleFonts.openSans(
              color: color,
              fontWeight: fontWeight,
              fontSize: size ?? 13.sp,
              decoration: decoration,
              fontStyle: fontStyle,
              foreground: foreground,
              shadows: shadows),
        );
      case TextType.selectable:
        w = SelectionArea(
          selectionControls: switch (Theme.of(context).platform) {
            TargetPlatform.android ||
            TargetPlatform.fuchsia =>
              MaterialTextSelectionControls(),
            TargetPlatform.linux ||
            TargetPlatform.windows =>
              desktopTextSelectionHandleControls,
            TargetPlatform.iOS => CupertinoTextSelectionControls(),
            TargetPlatform.macOS => cupertinoDesktopTextSelectionHandleControls,
          },
          child: AutoSizeText(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            minFontSize: minFontSize ?? 12,
            maxFontSize: maxFontSize ?? double.infinity,
            overflow: overflow,
            style: GoogleFonts.openSans(
              color: color,
              fontWeight: fontWeight,
              fontSize: size ?? 13.sp,
              decoration: decoration,
              fontStyle: fontStyle,
              foreground: foreground,
              shadows: shadows,
            ),
          ),
        );
    }
    return w;
  }
}
