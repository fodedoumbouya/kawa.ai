import 'package:flutter/foundation.dart';

import 'appRoutes.dart';
import 'dart:html' as html;

class AppNavigator {
  AppNavigator._();

  static void goHome() {
    AppRouter.router.go(AppRoutes.home);
  }

  static void goBack() {
    AppRouter.router.pop();
  }

  static void goLogin() {
    AppRouter.router.go(AppRoutes.login);
  }

  static void goSignUp() {
    AppRouter.router.go(AppRoutes.signUp);
  }

  static void goKitchen({required String projectID}) {
    return clearAndNavigate(AppRoutes.kitchen(projectID: projectID));
  }

  static void goChat() {
    AppRouter.router.go(AppRoutes.chat);
  }

  static void pushToNewTab(String location) {
    // if not in production, just navigate to the location in the same tab for the debug purpose
    if (kDebugMode) {
      AppRouter.router.go(location);
      return;
    }
    String url = location;
    if (!location.startsWith('http')) {
      url = "${Uri.base.origin}$location";
    }
    html.window.open(url, "");
  }

  static void clearAndNavigate(String path) {
    while (AppRouter.router.canPop() == true) {
      AppRouter.router.pop();
    }
    AppRouter.router.pushReplacement(path);
  }
}
