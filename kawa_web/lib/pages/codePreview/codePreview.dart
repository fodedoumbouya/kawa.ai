import 'package:flutter/material.dart';
import 'package:kawa_web/widgets/webView/webView.dart';

class CodePreview extends StatelessWidget {
  final String url;
  const CodePreview({required this.url, super.key});
  @override
  Widget build(BuildContext context) {
    return MyWebView(
      url: url,
    );
  }
}
