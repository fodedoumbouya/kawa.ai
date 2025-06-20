import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/common/utils/myLog.dart';
import 'package:kawa_web/config/config.dart';
import 'package:kawa_web/pages/root.dart';

Future<void> main() async {
  runZonedGuarded(
    () {
      Config.init(ProviderScope(child: Root()));
    },
    (Object error, StackTrace stackTrace) async {
      AppLog.d(
          "Error Thow\n--------------------------------\nError:  $error\n\nStackTrace:  $stackTrace");

      // _reportError(error, stackTrace);
    },
  );
}
