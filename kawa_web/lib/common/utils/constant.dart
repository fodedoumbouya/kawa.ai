import 'package:flutter_dotenv/flutter_dotenv.dart';

class KConstant {
  static const radius = 8.0;
  static const radiusBigger = 18.0;
  static const radiusPhone = 30.0;

  static const phoneHeight = 600.0;

  static const phoneWidth = 300.0;

  static String serverHost = dotenv.get("SERVER_HOST", fallback: "");

  static String downloadUrl = "http://$serverHost/api/download";
}
