part of "custom.dart";

class ContentChild {
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final void Function()? onTap;
  ContentChild({
    required this.text,
    this.icon,
    this.iconColor,
    this.textColor,
    this.onTap,
  });
}

class CustomPopUp extends StatelessWidget {
  final Widget child;
  final List<ContentChild> contentChild;
  CustomPopUp({required this.child, required this.contentChild, super.key});
  final GlobalKey<State<StatefulWidget>>? anchorKey =
      GlobalKey<State<StatefulWidget>>();
  @override
  Widget build(BuildContext context) {
    return CustomPopup(
      showArrow: true,
      anchorKey: anchorKey,

      // contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      barrierColor: Colors.transparent,
      contentDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KConstant.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        color: Theme.of(context).primaryColor,
      ),

      content: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            contentChild.length,
            (index) {
              final item = contentChild[index];
              final isLastIndex = index == contentChild.length - 1;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  item.onTap?.call();
                },
                child: CustomContainer(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  border: isLastIndex
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                  w: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomTextWidget(
                          item.text,
                          color: item.textColor,
                          size: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (item.icon != null)
                        Icon(
                          item.icon,
                          color: item.iconColor ?? Colors.black,
                          size: 10.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      child: child,
    );
  }
}
