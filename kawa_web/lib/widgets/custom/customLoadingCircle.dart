part of 'custom.dart';

class UiLoading extends StatelessWidget {
  const UiLoading({super.key, this.text, this.color});
  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomContainer(
          color: Colors.transparent,
          child: Center(
            child: SpinKitCircle(
              size: 20.sp,
              color: KColors.bc,
              // Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        text == null
            ? const SizedBox.shrink()
            : CustomTextWidget(text ?? "",
                color: KColors.bc, fontWeight: FontWeight.bold)
      ],
    );
  }
}
