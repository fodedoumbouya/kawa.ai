part of 'custom.dart';

class AppViewChildModel {
  final String title;
  final Widget child;
  bool isShow;
  AppViewChildModel(
      {required this.title, required this.child, this.isShow = false});

  copyWith({String? title, Widget? child, bool? isShow}) {
    return AppViewChildModel(
        title: title ?? this.title,
        child: child ?? this.child,
        isShow: isShow ?? this.isShow);
  }
}

class Sidebar extends StatelessWidget {
  // final Widget child;
  final bool showSidebar;
  // final String title;
  final List<AppViewChildModel> children;
  Sidebar(
      {required this.children,
      // required this.title,
      this.showSidebar = true,
      super.key});

  final isExpandedNotifier = ValueNotifier(true);

  final _showChild = ValueNotifier(true);
  final isShow = ValueNotifier<AppViewChildModel>(
      AppViewChildModel(title: '', child: const SizedBox(), isShow: false));

  @override
  Widget build(BuildContext context) {
    isShow.value = children.first;
    return ValueListenableBuilder(
        valueListenable: isExpandedNotifier,
        builder: (context, bool isExpanded, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            onEnd: () {
              _showChild.value = isExpanded;
            },
            width: isExpanded ? 33.w : 5.w,
            height: 100.h,
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(KConstant.radius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomContainer(
                    alig: Alignment.centerRight,
                    borderRadius: BorderRadius.circular(KConstant.radius),
                    allP: 10,
                    child: Row(
                      mainAxisAlignment: (showSidebar)
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _showChild,
                          builder: (context, value, child) {
                            if (!value) return const SizedBox.shrink();
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Row(
                                spacing: 2.w,
                                children: [
                                  ...children.map((e) => GestureDetector(
                                        onTap: () {
                                          for (var element in children) {
                                            element.isShow = false;
                                          }
                                          e.isShow = true;
                                          isShow.value = e;
                                          setState(() {});
                                        },
                                        child: CustomTextWidget(
                                          e.title,
                                          color: e.isShow
                                              ? Colors.black
                                              : Colors.black12,
                                          size: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                ],
                              );
                            });
                          },
                        ),

                        // ValueListenableBuilder(
                        //   valueListenable: _showChild,
                        //   builder: (context, value, _) {
                        //     return value
                        //         ? CustomTextWidget(
                        //             title,
                        //             color: Colors.black,
                        //             size: 13.sp,
                        //             fontWeight: FontWeight.bold,
                        //           )
                        //         : const SizedBox.shrink();
                        //   },
                        // ),
                        if (showSidebar)
                          IconButton(
                            padding: const EdgeInsets.all(8.0),
                            icon: Icon(
                              Icons.view_sidebar_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              isExpandedNotifier.value = !isExpanded;
                              if (isExpanded) {
                                _showChild.value = false;
                                _showChild.notifyListeners();
                              }
                            },
                          ),
                      ],
                    )),
                ValueListenableBuilder(
                  valueListenable: _showChild,
                  builder: (context, showChild, child) {
                    if (!showChild) return const SizedBox.shrink();
                    return ValueListenableBuilder(
                      valueListenable: isShow,
                      builder: (context, value, _) {
                        if (!value.isShow) return const SizedBox.shrink();
                        print("value.isShow ${value.isShow}");
                        return Flexible(
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(KConstant.radius),
                                child: DottedBackground(
                                  backgroundColor: Colors.white,
                                  dotColor: Colors.blue.withOpacity(0.2),
                                  child: value.child,
                                )));
                      },
                    );
                  },
                )
              ],
            ),
          );
        });
  }
}
