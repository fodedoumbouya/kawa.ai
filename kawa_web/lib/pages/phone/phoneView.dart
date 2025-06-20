import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/widgets/custom/custom.dart';
import 'package:kawa_web/widgets/webView/webView.dart';

class PhoneView extends StatelessWidget {
  final String url;
  final dynamic Function(InAppWebViewController)? onWebViewCreated;
  final Function(String src)? onUpdateVisitedHistory;

  const PhoneView(
      {required this.onWebViewCreated,
      this.onUpdateVisitedHistory,
      required this.url,
      super.key});

  @override
  Widget build(BuildContext context) {
    final bd = Theme.of(context).colorScheme.primaryContainer;
    final bp = Theme.of(context).primaryColor;
    return Stack(
      children: [
        CustomContainer(
          h: 100.h,
          w: 45.h,
          color: bp,
          borderRadius: BorderRadius.circular(5.h),
          allM: 20,
          boxShadow: [
            BoxShadow(
              color: bd.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: KColors.bcBlack,
              spreadRadius: 5,
              blurRadius: 0,
              offset: const Offset(-3, -3),
            ),
            BoxShadow(
              color: KColors.bcBlack,
              spreadRadius: 5,
              blurRadius: 0,
              offset: const Offset(3, 3),
            ),
          ],
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.h),
            child: IntrinsicHeight(
              child: MyWebView(
                onWebViewCreated: onWebViewCreated,
                onUpdateVisitedHistory: onUpdateVisitedHistory,
                url: url,
              ),
            ),
          ),
        )
      ],
    );
  }
}
