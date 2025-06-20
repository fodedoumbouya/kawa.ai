// ignore_for_file: use_build_context_synchronously

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/style/colors.dart';

import 'custom/custom.dart';

class CoreToast {
  CoreToast._();

  static showSuccess(String message, {int durationInSeconds = 3}) async {
    await WidgetsBinding.instance.endOfFrame;

    if (AppRouter.navigatorKey.currentContext == null) return;

    final context = AppRouter.navigatorKey.currentContext!;
    final bp = Theme.of(context).primaryColor;
    context.showToast(
      CustomTextWidget(message, color: bp, maxLines: 3),
      duration: Duration(seconds: durationInSeconds),
      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          0.5),
      queue: false,
      alignment: const Alignment(0.0, -1),
      backgroundColor: KColors.bcGreen,
    );
  }

  static showInfo(String message,
      {void Function()? onPressed,
      String? text,
      int durationInSeconds = 3}) async {
    assert(
        (onPressed == null && text == null) ||
            (onPressed != null && text != null),
        "onPressed and text must be both null or both not null");
    await WidgetsBinding.instance.endOfFrame;
    if (AppRouter.navigatorKey.currentContext == null) return;
    final context = AppRouter.navigatorKey.currentContext!;
    final bp = Theme.of(context).primaryColor;
    context.showToast(
      CustomTextWidget(message, color: bp, maxLines: 3),
      duration: Duration(seconds: durationInSeconds),
      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          0.5),
      queue: false,
      alignment: const Alignment(0.0, -1),
      backgroundColor: KColors.bcYellow,
    );
  }

  static showError(String message,
      {void Function()? onPressed,
      String? text,
      int durationInSeconds = 3}) async {
    assert(
        (onPressed == null && text == null) ||
            (onPressed != null && text != null),
        "onPressed and text must be both null or both not null");
    await WidgetsBinding.instance.endOfFrame;
    if (AppRouter.navigatorKey.currentContext == null) return;
    final context = AppRouter.navigatorKey.currentContext!;
    final bp = Theme.of(context).primaryColor;
    context.showToast(
      CustomTextWidget(
        message,
        color: bp,
        maxLines: 3,
      ),
      duration: Duration(seconds: durationInSeconds),
      backgroundColor: KColors.bcRed,
      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KConstant.radius),
              side: BorderSide(color: bp)),
          0.5),
      queue: false,
      alignment: const Alignment(0.0, -1),
    );
  }
}
