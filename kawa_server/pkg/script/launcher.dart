import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

Future _sendHotReload(
    {required int code,
    required String screen,
    required String projectId}) async {
  final messageEndpoint = 'http://localhost:8090/api/reload';
  final uri = Uri.parse(messageEndpoint);
  try {
    final response = await HttpClient().postUrl(uri)
      ..headers.contentType = ContentType.json
      // hot reload ==> 0, error ==> 1
      // ..write(jsonEncode({'message': "code"}));
      ..write(jsonEncode(
          {'code': '$code', 'screen': '$screen', 'projectId': '$projectId'}));
    final responseBody = await response.close().then((response) {
      return response.transform(utf8.decoder).join();
    });
    print('Message sent: $responseBody');
  } catch (e) {
    print('Error sending message: $e');
  }
}

Future<void> main(List<String> args) async {
// get project name from args

  if (args.isEmpty || args.length < 2) {
    print(
        'Please provide the project name and generated folder name as arguments.');
    exit(1);
  }
  final projectName = args[0];
  final projectId = projectName.split('_').last;
  final generatedFolderName = args[1];
  // print('projectName: $projectName');

  final currentPath = path.dirname(Platform.script.toFilePath());
// flutter run --machine -d web-server --web-hostname 0.0.0.0 --web-port 8080
  // Start the 'flutter run' daemon with --start-paused
  final libPath =
      path.join(currentPath, '../../$generatedFolderName/$projectName/lib/');
  // print('projectRootPath: $libPath');
  // /Users/fodedoumbouya/devCode/ff/kawa.ai/kawa_server/pkg/script/../../third_party/my_todo_app_2gimis4960x5h7q/lib/
  final watcher = DirectoryWatcher(libPath);

  int randomPort = Random().nextInt(5535) + 1000;

  // Check if port is available and regenerate if needed
  bool isPortAvailable = false;
  while (!isPortAvailable) {
    try {
      final socket = await ServerSocket.bind(
          InternetAddress.anyIPv4, randomPort,
          shared: true);
      await socket.close();
      isPortAvailable = true;
    } catch (e) {
      // Port is in use, generate new random port
      randomPort = Random().nextInt(5535) + 1000;
    }
  }

  final proc = await Process.start(
    'flutter',
    [
      'run',
      '--machine',
      '-d',
      'web-server',
      '--web-hostname',
      '0.0.0.0',
      '--web-port',
      '$randomPort',
    ],
    workingDirectory:
        path.join(currentPath, '../../$generatedFolderName/$projectName/'),
  );

  /// Completers to wait for the app.start, app.started and app.debugPort events.
//  proc.stdout
//       .transform(utf8.decoder)
//       .transform(const LineSplitter())
//       .listen((event) {
//     print('<== $event');
//   });

  final appStart = Completer<String>();
  final appStarted = Completer();
  final appDebugWsUri = Completer<String>();

  // Handle the incoming JSON to detect app.start, app.started and app.debugPort.
  proc.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((event) {
    print('<== $event');

    try {
      final json = jsonDecode(event);
      if (json
          case [{"event": "app.started", "params": {"appId": String appId}}]) {
        // [{'event': 'app.start', 'params': {'appId': String appId}}]) {
        appStart.complete(appId);
      } else if (json case [{'event': 'app.started'}]) {
        // print('App started ${json[0]}');
        appStarted.complete();
      }
//  code compile successully
      else if (json
          case [
            {
              'result': {
                'code': 0,
              }
            }
          ]) {
        // _sendHotReload(code: 0);
      } else if (json case [{'result': {'code': 1}}]) {
        print('Failed to recompile application.');
        // _sendHotReload(code: 1);
      } else if (json
          case [
            {'event': 'app.debugPort', 'params': {'wsUri': String wsUri}}
          ]) {
        appDebugWsUri.complete(wsUri);
      }
    } catch (e) {
      // non-json
    }
  });

//  wacth for file changes
  watcher.events.listen((event) async {
    print('File changed: ${event.path}');
    if (event.path.endsWith('.dart')) {
      final appId = await appStart.future;

      print('Sending hot reload');
      final payload = jsonEncode([
        {
          "id": 1,
          "method": "app.restart",
          "params": {
            "appId": appId,
            "fullRestart": true,
          }
        }
      ]);
      print('==> $payload');
      proc.stdin.writeln(payload);

      final screen = event.path.split('/').last.split(".dart").first;

      _sendHotReload(code: 0, screen: screen, projectId: projectId);

      if (event.path.endsWith('app_router.dart')) {
        // print('nameToPath: $nameToPath');
        // final nameToPath = _cacheNameToPath(
        //     '',
        //     router
        //         .AppRouter.router.routeInformationParser.configuration.routes);
        // print('nameToPath: $nameToPath');
      }
    }
  });

  // await appStarted.future;
  // final appId = await appStart.future;
  // // final wsUri = await appDebugWsUri.future;
  // print('\n\n\n\n\nApp started with appId: $appId \n\n\n\n\n');

  // final vmService = await vmServiceConnectUri(wsUri);

  // Since we used start-paused, we need to resume the isolates.
  // await resumeAllIsolates(vmService);

  // Send two hot reloads WITHOUT an unpause in between.
  // for (int i = 0; i <= 1; i++) {
  //   await Future.delayed(const Duration(seconds: 3));
  //   final payload = jsonEncode([
  //     {
  //       "id": i,
  //       "method": "app.restart",
  //       "params": {
  //         "appId": appId,
  //         "fullRestart": true,
  //       }
  //     }
  //   ]);
  //   print('==> $payload');
  //   proc.stdin.writeln(payload);
  // }

  // Repeatedly ensure all isolates are resumed (usually the IDE would notice
  // new paused isolates, send breakpoints and then resume them).
  // for (int i = 1; i <= 20; i++) {
  //   await Future.delayed(const Duration(seconds: 2));
  //   await resumeAllIsolates(vmService);
  // }

  // print('Done! Did everything complete?');

  await proc.exitCode;
}

/// Resume all isolates. Since we're using --pause-on-start, new isolates
/// created during a restart will start paused and the IDE/debug adapter will
/// usually unpause them.
// Future<void> resumeAllIsolates(VmService vmService) async {
//   await Future.wait((await vmService.getVM())
//       .isolates!
//       .map((isolate) => tryResume(vmService, isolate)));
// }

// /// Attempt to resume an isolate only if it's paused, and print if it fails.
// Future<Success> tryResume(VmService vmService, IsolateRef isolateRef) async {
//   final isolate = await vmService.getIsolate(isolateRef.id!);
//   if (isolate.pauseEvent == null ||
//       isolate.pauseEvent?.kind == EventKind.kResume) {
//     // Isolate is not paused.
//     return Success();
//   }

//   try {
//     return await vmService.resume(isolate.id!);
//   } catch (e) {
//     print('Failed to resume Isolate "${isolate.id}": $e');
//     return Success();
//   }
// }
