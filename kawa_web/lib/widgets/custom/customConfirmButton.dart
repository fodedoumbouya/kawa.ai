part of 'custom.dart';

class ConfirmButton extends StatelessWidget {
  final String txt;
  final double allM;
  final double txtSize;
  final Color? textColor;
  final double? h;
  final double? widthPourcent;
  final Color? bColor;
  final Color? borderColor;
  final double? elevation;
  final double radius;
  final void Function() onPressed;
  final double? width;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const ConfirmButton({
    super.key,
    required this.txt,
    this.allM = 10.0,
    this.txtSize = 20.0,
    this.textColor,
    this.radius = KConstant.radius,
    this.h,
    this.widthPourcent,
    this.bColor,
    this.borderColor,
    required this.onPressed,
    this.elevation,
    this.width,
    this.maxLines,
    this.textAlign,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final widthFactor = widthPourcent ?? (Device.isMobile ? 100 : 30);
    return CustomContainer(
      allM: allM,
      h: h ?? 5.h, // 5.h = 5%
      w: width ?? 100.w, // 100.w = 100%
      child: FractionallySizedBox(
        widthFactor: widthFactor / 100,
        child: ElevatedButton(
            style: ButtonStyle(
              elevation:
                  elevation == null ? null : WidgetStateProperty.all(elevation),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(bColor ?? KColors.bc),
              side: borderColor == null
                  ? null
                  : WidgetStateProperty.all(BorderSide(
                      color: borderColor ?? Colors.transparent,
                      width: 1.0,
                      style: BorderStyle.solid)),
            ),
            onPressed: onPressed,
            child: CustomTextWidget(
              txt,
              color: textColor ?? Theme.of(context).primaryColor,
              size: txtSize.sp,
              maxLines: maxLines,
              textAlign: textAlign,
              fontWeight: fontWeight,
            )),
      ),
    );
  }
}
