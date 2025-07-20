import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/base/baseStateNotifier.dart';
import 'package:kawa_web/base/repo/user/logic.dart';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/model/generated/user.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

// late TransText transText;

abstract class BaseWidget extends ConsumerStatefulWidget {
  const BaseWidget({super.key});

  @override
  BaseWidgetState createState() {
    return getState();
  }

  BaseWidgetState getState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends ConsumerState<T>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // / Register your State class as a binding observer
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    // Unregister your State class as a binding observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // AppLog.v("didChangeDependencies: ${widget.toString()}\n");
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // AppLog.d("didChangeAppLifecycleState: $state");
    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
        _onInactive();
      case AppLifecycleState.hidden:
        _onHidden();
      case AppLifecycleState.paused:
        _onPaused();
    }
  }

  void _onDetached() => debugPrint('detached');
  void _onResumed() => debugPrint('resumed');
  void _onInactive() => debugPrint('inactive');
  void _onHidden() => debugPrint('hidden');
  void _onPaused() => debugPrint('paused');

  /// Return background color always blue
  Color bc() {
    return Theme.of(context).colorScheme.primary;
  }

// Return  color always grey
  Color bcGrey() {
    return KColors.bcGrey;
    // const Color.fromRGBO(98, 99, 102, 1);
  }

  /// return White/Black on theme mode (light/dark)
  Color bp() {
    return Theme.of(context).primaryColor;
  }

  /// return Black/White on theme mode (light/dark)
  Color bd() {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color bdDark() {
    return Theme.of(context).colorScheme.shadow;
  }

  Color bpLight() {
    return Theme.of(context).colorScheme.onPrimary;
  }

  Color bcPurple() {
    return Theme.of(context).colorScheme.onSecondaryContainer;
  }

  Future toPage(Widget w) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return w;
    }));
  }

  void jumpToPage(Widget w) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return w;
    }));
  }

  void pop([Object? o]) {
    Navigator.of(context).pop(o);
  }

  //get Unique ID
  String getUniqueID() {
    return const Uuid().v4();
  }

  /// This function is used to get the user data from the local state
  UserModel? getUser() {
    if (!mounted) return null;
    UserNotifier userNotifier = userProvider.getFunction(ref);
    return userNotifier.getUser;
  }

  rebuildState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future myLauncherHtmlWithHeaders({
    required String url,
  }) async {
    assert(url.isNotEmpty, "URL should not be empty");
    debugPrint("Launching: $url");
    // Get the auth token
    html.window.open(
        "$url/Bearer ${DataPersistence.getAccount()?.tokenKey}", '_blank');
  }
}
