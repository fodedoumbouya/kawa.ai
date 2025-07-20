import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kawa_web/common/dataPersitence/spUtil.dart';
import 'package:kawa_web/common/utils/network/dio.dart';
import 'package:kawa_web/core/creatingProjectListener/creatingProjectListener.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

class Config {
  static Future init(Widget entryPoint) async {
    usePathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    DioUtil.init();
    await SpUtil.getInstance();
    CreatingProjectListener.instance.initialize();

    runApp(entryPoint);
  }
}
