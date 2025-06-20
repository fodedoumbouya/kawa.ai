import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/myLog.dart';
import 'package:kawa_web/model/generated/gitResponse.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// -------- dio ----------------- pour upload file

var dio = Dio();

class DioUtil {
  static final DioUtil _singleton = DioUtil._internal();
  factory DioUtil() {
    return _singleton;
  }

  DioUtil._internal();
  // static late Directory tempDir;
  // static late Directory appDir;

  static init() {
    dio
      ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: false,
        responseHeader: true,
        maxWidth: 10,
        responseBody: false,
      ))
      // ..interceptors.add(HttpFormatter())
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); //continue
      }, onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
      }, onError: (DioException e, handler) {
        // Do something with response error
        return handler.next(e); //continue
      }));

    // dio config
    dio.options.baseUrl = 'http://${KConstant.serverHost}/api';
    dio.options.connectTimeout = const Duration(seconds: 180);
    dio.options.receiveTimeout = const Duration(minutes: 5);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Access-Control-Allow-Origin'] = '';
        options.headers['Accept'] = '';
        options.headers['Authorization'] =
            'Bearer ${DataPersistence.getAccount()?.tokenKey}';

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log the response data
        AppLog.i('Response Status: ${response.statusCode}');
        AppLog.i('Response Data: ${response.data}');
        return handler.next(response); // Proceed with the response
      },
      onError: (DioException error, handler) {
        // Handle errors
        AppLog.e("Error$error");

        return handler.next(error); // Proceed with error handling
      },
    ));
  }

  static Future<Response> get({
    required String url,
  }) async {
    try {
      var result = await dio.get(url);
      return result;
    } catch (error) {
      if (error is DioException) {
        return Future.error(error);
      }
      return Future.error(error);
    }
  }

  static Future<Response> post(
      {required String url,
      required dynamic data,
      Map<String, dynamic>? headers}) async {
    try {
      headers ??= {};
      final apiKey = DataPersistence.getApiSetting()?.api_key;
      final modelHost = DataPersistence.getApiSetting()?.model_host;
      final modelName = DataPersistence.getApiSetting()?.model_name;
      if (apiKey != null &&
          apiKey.isNotEmpty &&
          modelHost != null &&
          modelHost.name.isNotEmpty &&
          modelName != null &&
          modelName.isNotEmpty) {
        headers['Llm_key'] = apiKey;
        headers['Llm_host'] = modelHost.name;
        headers['Llm_model'] = modelName;
      }

      var result =
          await dio.post(url, data: data, options: Options(headers: headers));
      return result;
    } catch (error) {
      rethrow;
    }
  }

  static Future<String?> downloadImageAndSaved(
      {required String url,
      required Directory tempDir,
      required Directory appDir}) async {
    try {
      final resp = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      if (resp.statusCode == 200) {
        final bytes = resp.data;

        final imageName = url.split('/').last.replaceAll(".png", "");

        // Get the app's temporary directory
        final file = File('${tempDir.path}/$imageName.png');

        // Save the image to the app's assets directory
        await file.writeAsBytes(bytes);
        final assetFile = await file.copy('${appDir.path}/$imageName.png');
        return assetFile.path;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> downloadImage({required String url}) async {
    try {
      final resp = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      if (resp.statusCode == 200) {
        return resp.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isServerRunning(String? url) async {
    if (url == null) {
      return false;
    }
    try {
      final response = await dio.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// startServer
  static Future<String?> startServer(String projectId) async {
    final url = '/runProject/$projectId';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> stopServer(String projectId) async {
    final url = '/stopProject/$projectId';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> sendPrompt(
      {required String projectId,
      required String prompt,
      required String currentScreen}) async {
    try {
      Map<String, dynamic> headers = {};
      final apiKey = DataPersistence.getApiSetting()?.api_key;
      final modelHost = DataPersistence.getApiSetting()?.model_host;
      final modelName = DataPersistence.getApiSetting()?.model_name;
      if (apiKey != null &&
          apiKey.isNotEmpty &&
          modelHost != null &&
          modelHost.name.isNotEmpty &&
          modelName != null &&
          modelName.isNotEmpty) {
        headers['Llm_key'] = apiKey;
        headers['Llm_host'] = modelHost.name;
        headers['Llm_model'] = modelName;
      }

      final response = await dio.post("/editScreen",
          data: {
            "projectId": projectId,
            "currentScreen": currentScreen,
            "prompt": prompt
          },
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      AppLog.e("Error in sendPrompt: $e");
      return null;
    }
  }

  static Future<bool> deleteProject(String projectId) async {
    try {
      final response = await dio.delete("/project/$projectId");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      AppLog.e("Error: $e");
      return false;
    }
  }

  static Future<GitResponse> undoRedoStatus(String projectId) async {
    try {
      final resp = await dio.post("/git/status", data: {
        "projectId": projectId,
      });
      if (resp.statusCode == 200) {
        return GitResponseMapper.fromMap(resp.data);
      } else {
        return GitResponse(success: false);
      }
    } catch (e) {
      AppLog.e("Error: $e");
      return GitResponse(success: false);
    }
  }

  static Future<GitResponse> undo(String projectId) async {
    try {
      final resp = await dio.post("/git/backward", data: {
        "projectId": projectId,
      });
      if (resp.statusCode == 200) {
        return GitResponseMapper.fromMap(resp.data);
      } else {
        return GitResponse(success: false);
      }
    } catch (e) {
      AppLog.e("Error: $e");
      return GitResponse(success: false);
    }
  }

  static Future<GitResponse> redo(String projectId) async {
    try {
      final resp = await dio.post("/git/forward", data: {
        "projectId": projectId,
      });
      if (resp.statusCode == 200) {
        return GitResponseMapper.fromMap(resp.data);
      } else {
        return GitResponse(success: false);
      }
    } catch (e) {
      AppLog.e("Error: $e");
      return GitResponse(success: false);
    }
  }
}
