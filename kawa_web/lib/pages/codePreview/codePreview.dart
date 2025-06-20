import 'package:flutter/material.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/widgets/webView/webView.dart';

class CodePreview extends BaseWidget {
  final String url;
  const CodePreview({required this.url, super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CodePreviewState();
  }
}

class _CodePreviewState extends BaseWidgetState<CodePreview> {
  @override
  Widget build(BuildContext context) {
    return MyWebView(
      url: widget.url,
    );
  }
}
