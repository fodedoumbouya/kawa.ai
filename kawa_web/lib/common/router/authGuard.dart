import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/base/baseStateNotifier.dart';
import 'package:kawa_web/base/repo/user/logic.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/model/generated/user.dart';

class Guard extends StatelessWidget {
  final bool canActivate;
  final Widget child;
  final String fallbackRoute;
  const Guard({
    super.key,
    required this.canActivate,
    required this.child,
    required this.fallbackRoute,
  });
  @override
  Widget build(BuildContext context) {
    if (canActivate) {
      return child;
    }
    redirect(context);
    return const SizedBox.shrink();
  }

  void redirect(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppNavigator.clearAndNavigate(fallbackRoute);
    });
  }
}

class AuthGuard extends ConsumerWidget {
  final String fallbackRoute;
  final Widget Function() childBuilder;
  const AuthGuard({
    super.key,
    required this.fallbackRoute,
    required this.childBuilder,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = (userProvider.getState(ref) as UserModel?);
    return Guard(
      canActivate: user != null,
      fallbackRoute: fallbackRoute,
      child: childBuilder(),
    );
  }
}
