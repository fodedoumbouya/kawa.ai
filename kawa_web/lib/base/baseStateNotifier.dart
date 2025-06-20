import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  BaseStateNotifier(super.state) {
    debugPrint("--------------------$T: initialize");
  }
}

extension GetState on StateNotifierProvider {
  getState<T>(WidgetRef ref) {
    return ref.watch(this) as T;
  }

  getFunction<T>(WidgetRef ref) {
    return ref.read(notifier) as T;
  }
}
