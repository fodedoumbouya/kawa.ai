import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kawa_web/common/router/authGuard.dart';
import 'package:kawa_web/pages/home/homePage.dart';
import 'package:kawa_web/pages/kitchen/kitchen.dart';
import 'package:kawa_web/pages/login/login.dart';
import 'package:kawa_web/pages/login/signUp.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

part 'routes.dart';

class AppRouter {
  AppRouter._privateConstructor();
  static final AppRouter instance = AppRouter._privateConstructor();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    routes: routes,
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
