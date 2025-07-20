import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/resizeRootApp.dart';
import 'package:kawa_web/common/utils/style/theme.dart';

class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// [LayoutBuilder] is used to get the size given to the app by the OS
    /// [ResponsiveSizer] is used to get the screen type, orientation and the size
    return LayoutBuilder(builder: (contextResize, constraints) {
      // resize the app when the given screen size changes
      ResizeRootApp.instance.resizeUpdate(contextResize);
      return ResponsiveSizer(
        key: ResizeRootApp.instance.globalKey,
        builder: (context, orientation, screenType) {
          return MaterialApp.router(
            title: "Kawa.ai",
            theme: KTheme.lightTheme(),
            darkTheme: KTheme.dartTheme(),
            themeMode: ThemeMode.light, // force light theme for now
            debugShowCheckedModeBanner: false,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
            routeInformationParser: AppRouter.router.routeInformationParser,
            routerDelegate: AppRouter.router.routerDelegate,
            builder: (context, child) {
              final childWithToast = Toast(
                  navigatorKey: AppRouter.navigatorKey,
                  child: child ?? const SizedBox.shrink());

              return Scaffold(
                body: childWithToast,
              );
            },
          );
        },
      );
    });
  }
}
