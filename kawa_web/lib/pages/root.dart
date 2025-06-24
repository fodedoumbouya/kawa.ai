import 'package:flash/flash_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/resizeRootApp.dart';
import 'package:kawa_web/common/utils/style/theme.dart';

class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // transText = (langProvider.getState(ref) as TransText);

    /// [LayoutBuilder] is used to get the size given to the app by the OS
    /// [ResponsiveSizer] is used to get the screen type, orientation and the size
    return LayoutBuilder(builder: (contextResize, constraints) {
      // resize the app when the given screen size changes
      ResizeRootApp.instance.resizeUpdate(contextResize);
      return ResponsiveSizer(
        key: ResizeRootApp.instance.globalKey,
        builder: (context, orientation, screenType) {
          return MaterialApp.router(
            // title: transText.appName,
            title: "Kawa Web",
            theme: KTheme.lightTheme(),
            darkTheme: KTheme.dartTheme(),
            // themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            // navigatorKey: NavigatorUtils.instance.navigatorKey,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
            routeInformationParser: AppRouter.router.routeInformationParser,
            routerDelegate: AppRouter.router.routerDelegate,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // locale: transText.lang == Lang.fr_FR
            //     ? const Locale('fr', 'FR')
            //     : const Locale('en', 'US'),

            // supportedLocales: const [
            //   Locale('fr', 'FR'),
            //   Locale('en', 'US'),
            // ],
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
