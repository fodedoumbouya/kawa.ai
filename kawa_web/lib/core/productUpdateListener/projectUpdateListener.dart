import 'dart:async';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:web_socket_client/web_socket_client.dart';

class ProjectUpdateListener {
  ProjectUpdateListener._();
  static final ProjectUpdateListener instance = ProjectUpdateListener._();
  factory ProjectUpdateListener() => instance;

  // Instance method that delegates to static init method
  Future<void> initialize({required String projectId}) async =>
      await ProjectUpdateListener.init(projectId: projectId);

  // broadcast stream to listen to multiple listeners
  static final StreamController<String> streamController =
      StreamController<String>.broadcast();

  static final _serverUrl = 'ws://${KConstant.serverHost}/api/subscribe';

  static WebSocket? _webSocket;
  static bool _initializing = false;
  static Completer<void>? _initCompleter;

  static Future<void> init({required String projectId}) async {
    // If already initialized, return immediately
    if (_webSocket != null) {
      return;
    }
    // If currently initializing, wait for it to complete
    if (_initializing) {
      await _initCompleter!.future;
      return;
    }

    // Start initialization
    _initializing = true;
    _initCompleter = Completer<void>();

    try {
      // Connect to the WebSocket server
      _webSocket = WebSocket(Uri.parse("$_serverUrl/$projectId"),
          timeout: Duration(minutes: 2));

      // Listen for incoming messages
      _webSocket!.messages.listen(
        (code) {
          // print('Received: $code');
          streamController.add(code);
        },
        onDone: () {
          // print('Connection closed.');
          _webSocket = null; // Allow reconnection if needed
        },
        onError: (error) {
          // print('Error: $error');
          _webSocket = null; // Allow reconnection if needed
        },
      );

      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _webSocket = null;
      rethrow;
    } finally {
      _initializing = false;
    }
  }
}
