import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyWebView extends StatelessWidget {
  final dynamic Function(InAppWebViewController)? onWebViewCreated;
  final String url;
  final Function(String src)? onPageFinished;
  final Function(String src)? onPageStarted;
  final Function(String src)? onUpdateVisitedHistory;

  const MyWebView(
      {this.onWebViewCreated,
      required this.url,
      this.onPageFinished,
      this.onPageStarted,
      this.onUpdateVisitedHistory,
      super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final s = constraints.biggest;
      return FittedBox(
        child: SizedBox(
          height: s.height,
          width: s.width,
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(),
            onWebViewCreated: (controller) {
              onWebViewCreated?.call(controller);
            },
            onLoadStart: (controller, url) {
              debugPrint('A new page has started loading: $url\n');
              onPageStarted?.call(url.toString());
            },
            onLoadStop: (controller, url) async {
              debugPrint('The page has finished loading: $url\n');
              onPageFinished?.call(url.toString());
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              debugPrint('The page has finished loading: $url\n');
              onUpdateVisitedHistory?.call(url.toString());
            },
          ),
        ),
      );
    });
  }
}
