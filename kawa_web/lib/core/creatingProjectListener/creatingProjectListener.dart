import 'dart:async';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:web_socket_client/web_socket_client.dart';

class CreatingProjectListener {
  CreatingProjectListener._();
  static final CreatingProjectListener instance = CreatingProjectListener._();
  factory CreatingProjectListener() => instance;

  // Instance method that delegates to static init method
  Future<void> initialize() async => await CreatingProjectListener.init();

  // broadcast stream to listen to multiple listeners
  static final StreamController<String> streamController =
      StreamController<String>.broadcast();

  static final _serverUrl =
      'ws://${KConstant.serverHost}/api/subscribeProjectProgress'; // WebSocket server URL

  static WebSocket? _webSocket;
  static bool _initializing = false;
  static Completer<void>? _initCompleter;

  static Future<void> init() async {
    // If already initialized, return immediately
    if (_webSocket != null) {
      return;
    }
    final clientId = DataPersistence.getAccount()?.id;
    final server = '$_serverUrl?clientId=$clientId';

    // If currently initializing, wait for it to complete
    if (_initializing) {
      await _initCompleter!.future;
      return;
    }

    // Start initialization
    _initializing = true;
    _initCompleter = Completer<void>();
    String lastMessage = '';
    try {
      // Connect to the WebSocket server
      _webSocket = WebSocket(Uri.parse(server));

      // Listen for incoming messages
      _webSocket!.messages.listen(
        (code) {
          // Check if the message is different from the last one
          if (code == lastMessage) {
            return; // Ignore duplicate messages
          }
          lastMessage = code; // Update the last message
          // App('Received 22: $code');
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
