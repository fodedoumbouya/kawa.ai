import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/myLog.dart';
import 'package:kawa_web/common/utils/network/dio.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/core/productUpdateListener/projectUpdateListener.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/model/generated/gitResponse.dart';
import 'package:kawa_web/model/generated/project.dart';
import 'package:kawa_web/pages/chat/chat.dart';
import 'package:kawa_web/pages/codePreview/codePreview.dart';
import 'package:kawa_web/pages/phone/phoneView.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class Kitchen extends BaseWidget {
  final String projectId;
  const Kitchen({required this.projectId, super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _KitchenState();
  }
}

class _KitchenState extends BaseWidgetState<Kitchen> {
  final showCodePreview = ValueNotifier<bool>(false);
  InAppWebViewController? webviewController;
  final _loading = ValueNotifier<bool>(false);
  final project = ValueNotifier<Project?>(null);
  final _host = ValueNotifier<String?>(null);
  final _processRunningStoping =
      ValueNotifier<bool>(false); // check if the process is running
  final _isServerRunning =
      ValueNotifier<bool>(false); // check if the server is running
  final TextEditingController _chatController = TextEditingController();
  String? designReference;
  final _canUndoRedoStatus =
      ValueNotifier<GitResponse>(GitResponse(success: false));
  String? previewCodeUrl;
  String? currentScreenHistory;

  getProject() async {
    _loading.value = true;
    project.value = await UserManagement.getProject(widget.projectId);
    _host.value = await UserManagement.getProjectHost(widget.projectId);
    _isServerRunning.value = await DioUtil.isServerRunning(widget.projectId);
    _loading.value = false;
  }

  void getPreviewCodeUrl() async {
    final resp = await DioUtil.get(url: "/getVscode/${widget.projectId}");
    if (resp.statusCode == 200) {
      previewCodeUrl = resp.data["url"];
    }
  }

  @override
  void initState() {
    super.initState();
    getProject();
    getUndoRedoStatus();
    getPreviewCodeUrl();
    // Initialize the WebSocket connection for project updates (to notify about changes)
    ProjectUpdateListener.instance
        .initialize(projectId: widget.projectId)
        .then((_) {
      ProjectUpdateListener.streamController.stream.listen((event) async {
        final data = jsonDecode(event);
        if (data["code"] == "0") {
          await Future.delayed(const Duration(milliseconds: 100));
          // Refresh the project data
          final currentUrl = await webviewController?.getUrl();
          if (currentUrl != null) {
            webviewController?.loadUrl(
              urlRequest: URLRequest(url: currentUrl),
            );
          } else if (currentScreenHistory != null) {
            webviewController?.loadUrl(
              urlRequest: URLRequest(url: WebUri(currentScreenHistory!)),
            );
          } else {
            webviewController?.reload();
          }
          getUndoRedoStatus();
        }
      });
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    project.dispose();
    _host.dispose();
    _processRunningStoping.dispose();
    _isServerRunning.dispose();
    showCodePreview.dispose();
    _canUndoRedoStatus.dispose();
    webviewController?.dispose();
    webviewController = null;
    previewCodeUrl = null;
    // _selectedPath.dispose();
    ProjectUpdateListener.streamController.close();
    AppLog.d("Kitchen disposed");
    super.dispose();
  }

  void getUndoRedoStatus() async {
    _canUndoRedoStatus.value = await DioUtil.undoRedoStatus(widget.projectId);
  }

  void undo() async {
    if (_canUndoRedoStatus.value.canBackward ?? false) {
      final resp = await DioUtil.undo(widget.projectId);
      if (resp.success) {
        // getUndoRedoStatus();
        CoreToast.showSuccess(resp.message ?? "Undo success");
      } else {
        CoreToast.showError("Undo failed");
      }
    } else {
      CoreToast.showError("Undo not available");
    }
  }

  void redo() async {
    if (_canUndoRedoStatus.value.canForward ?? false) {
      final resp = await DioUtil.redo(widget.projectId);
      if (resp.success) {
        // getUndoRedoStatus();
        CoreToast.showSuccess(resp.message ?? "Redo success");
      } else {
        CoreToast.showError("Redo failed");
      }
    } else {
      CoreToast.showError("Redo not available");
    }
  }

  Future runStopProject() async {
    if (_processRunningStoping.value) return;

    _processRunningStoping.value = true;
    if (_isServerRunning.value) {
      final resp = await DioUtil.stopServer(widget.projectId);
      if (!mounted) return;
      if (resp != null) {
        _isServerRunning.value = false;
        _host.value = null;
        AppLog.d("Server stopped: $resp");
      } else {
        CoreToast.showError("Server not stopped");
      }
    } else {
      // _isServerRunning.value = true;
      final resp = await DioUtil.startServer(widget.projectId);
      if (resp != null) {
        _isServerRunning.value = true;
        _host.value = resp;
        webviewController?.loadUrl(
          urlRequest: URLRequest(url: WebUri("${_host.value}")),
        );
        AppLog.d("Server started: $resp");
      } else {
        CoreToast.showError("Server not started");
      }
    }
    _processRunningStoping.value = false;
  }

  void sendPompt(String text) async {
    if (text.isEmpty) return;
    final currentUrl = await webviewController?.getUrl();
    String? currentScreen = currentUrl?.toString().split("/").last;
    if (currentUrl != null && currentUrl.toString().endsWith("/")) {
      currentScreen = "home";
    }
    if (currentScreen == null || currentScreen.isEmpty) {
      CoreToast.showError("Current screen not found");
      return;
    }

    final resp = await DioUtil.sendPrompt(
      projectId: widget.projectId,
      prompt: text,
      currentScreen: currentScreen,
    );
    AppLog.i("Response: $resp");
  }

  _downloadProject() async {
    if (project.value == null) return;

    await myLauncherHtmlWithHeaders(
        url: "${KConstant.downloadUrl}/${project.value!.id}");

    return;
  }

  @override
  Widget build(BuildContext context) {
    final sizeLeft = 100.w - (40.w + 45.h);
    return Scaffold(
        body: SizedBox(
            width: 100.w,
            height: 100.h,
            child: ValueListenableBuilder(
                valueListenable: _loading,
                builder: (context, value, child) {
                  if (value) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (project.value == null) {
                    return Center(
                      child: CustomTextWidget("No project found"),
                    );
                  }
                  final projectName = project.value?.projectName ?? "";
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomContainer(
                        h: 50,
                        w: 100.w,
                        color: bc(),
                        child: Row(
                          children: [
                            CustomContainer(
                              w: 40.w,
                              h: 50,
                              border: Border.all(
                                  color: bd().withValues(alpha: 0.1)),
                              child: Row(
                                children: [
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      // if the code preview is open, close it
                                      if (showCodePreview.value) {
                                        showCodePreview.value = false;
                                        return;
                                      }

                                      if (_isServerRunning.value) {
                                        runStopProject();
                                      }
                                      AppNavigator.clearAndNavigate(
                                          AppRoutes.home);
                                    },
                                    child: CustomContainer(
                                      borderRadius: BorderRadius.circular(
                                          KConstant.radius),
                                      allP: 5,
                                      color: bc(),
                                      mouseRegion: true,
                                      border: Border.all(
                                          color: bd().withValues(alpha: 0.1),
                                          width: 1),
                                      child: Icon(Icons.arrow_back),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  CustomTextWidget(
                                    projectName,
                                    size: 12.sp,
                                    color: bd(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                            CustomContainer(
                              w: 45.h,
                              h: 50,
                              border: Border.all(
                                  color: bd().withValues(alpha: 0.1)),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  CustomTextWidget(
                                    "Project view",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Spacer(),

                                  CustomContainer(
                                    borderRadius:
                                        BorderRadius.circular(KConstant.radius),
                                    allP: 5,
                                    color: bc(),
                                    mouseRegion: true,
                                    border: Border.all(
                                        color: bd().withValues(alpha: 0.1),
                                        width: 1),
                                    child: ValueListenableBuilder(
                                      valueListenable: _isServerRunning,
                                      builder: (context, value, child) {
                                        return GestureDetector(
                                          onTap: () async {
                                            runStopProject();
                                          },
                                          child: ValueListenableBuilder(
                                            valueListenable:
                                                _processRunningStoping,
                                            builder:
                                                (context, onProcessing, child) {
                                              if (onProcessing) {
                                                return SizedBox(
                                                  width: 11.sp,
                                                  height: 11.sp,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: KColors.bcBlue,
                                                  ),
                                                );
                                              }
                                              return Icon(
                                                  value
                                                      ? Icons
                                                          .stop_circle_outlined
                                                      : Icons.play_arrow,
                                                  size: 11.sp,
                                                  color: bd());
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Icon(Icons.play_arrow)
                                ],
                              ),
                            ),
                            Expanded(
                                child: CustomContainer(
                              border: Border.all(
                                  color: bd().withValues(alpha: 0.1)),
                              alig: Alignment.center,
                              child: Row(
                                children: [
                                  SizedBox(width: 1.w),
                                  CustomTextWidget(
                                    "Code view",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Spacer(),
                                  ValueListenableBuilder(
                                    valueListenable: _canUndoRedoStatus,
                                    builder: (context, value, child) {
                                      return CustomContainer(
                                        borderRadius: BorderRadius.circular(
                                            KConstant.radius),
                                        border: Border.all(
                                            color: bd().withValues(alpha: 0.1),
                                            width: 1),
                                        allP: 5,
                                        child: Row(
                                          spacing: 1.w,
                                          children: [
                                            CustomTextWidget("Git Actions",
                                                size: 9.sp, color: bcGrey()),
                                            GestureDetector(
                                              onTap: () => undo(),
                                              child: CustomContainer(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        KConstant.radius),
                                                allP: 5,
                                                color: (value.canBackward ??
                                                        false)
                                                    ? bc()
                                                    : bd()
                                                        .withValues(alpha: 0.1),
                                                mouseRegion: true,
                                                border: Border.all(
                                                    color: bd()
                                                        .withValues(alpha: 0.1),
                                                    width: 1),
                                                child: Icon(Icons.undo,
                                                    size: 11.sp),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => redo(),
                                              child: CustomContainer(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        KConstant.radius),
                                                allP: 5,
                                                color: (value.canForward ??
                                                        false)
                                                    ? bc()
                                                    : bd()
                                                        .withValues(alpha: 0.1),
                                                mouseRegion: true,
                                                border: Border.all(
                                                    color: bd()
                                                        .withValues(alpha: 0.1),
                                                    width: 1),
                                                child: Icon(Icons.redo,
                                                    size: 11.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 1.w),
                                  GestureDetector(
                                    onTap: () async {
                                      if (previewCodeUrl == null) {
                                        CoreToast.showError(
                                            "Code preview not available");
                                        return;
                                      }

                                      showCodePreview.value =
                                          !showCodePreview.value;
                                    },
                                    child: CustomContainer(
                                      borderRadius: BorderRadius.circular(
                                          KConstant.radius),
                                      allP: 5,
                                      color: bc(),
                                      mouseRegion: true,
                                      border: Border.all(
                                          color: bd().withValues(alpha: 0.1),
                                          width: 1),
                                      child: Icon(Icons.code),
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  GestureDetector(
                                    onTap: () {
                                      LoadingView(context: context).wrap(
                                          asyncFunction: () =>
                                              _downloadProject());
                                    },
                                    child: CustomContainer(
                                      borderRadius: BorderRadius.circular(
                                          KConstant.radius),
                                      allP: 5,
                                      color: bc(),
                                      mouseRegion: true,
                                      border: Border.all(
                                          color: bd().withValues(alpha: 0.1),
                                          width: 1),
                                      child: Icon(Icons.file_download_outlined),
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          physics: ClampingScrollPhysics(),
                          child: ValueListenableBuilder(
                              valueListenable: showCodePreview,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!value)
                                      CustomContainer(
                                          w: 40.w,
                                          h: 100.h,
                                          border: Border.all(
                                              color:
                                                  bd().withValues(alpha: 0.1)),
                                          child: Chat(
                                            projectId: widget.projectId,
                                            controller: _chatController,
                                            onSubmitted: (text) {
                                              sendPompt(text);
                                            },
                                          )),
                                    CustomContainer(
                                        w: 45.h,
                                        h: 100.h,
                                        border: Border.all(
                                            color: bd().withValues(alpha: 0.1)),
                                        child: Stack(
                                          children: [
                                            ValueListenableBuilder(
                                              valueListenable: _host,
                                              builder: (context, host, child) {
                                                return PhoneView(
                                                  url: host ?? "",
                                                  onWebViewCreated: (p0) {
                                                    webviewController = p0;
                                                  },
                                                  onUpdateVisitedHistory:
                                                      (src) {
                                                    currentScreenHistory = src;
                                                  },
                                                );
                                              },
                                            ),
                                            ValueListenableBuilder(
                                                valueListenable:
                                                    _processRunningStoping,
                                                builder:
                                                    (context, value, child) {
                                                  return value
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                KColors.bcBlue,
                                                          ),
                                                        )
                                                      : SizedBox.shrink();
                                                }),
                                          ],
                                        )),
                                    CustomContainer(
                                      h: 100.h,
                                      w: value ? (100.w - 47.h) : sizeLeft,
                                      border: Border.all(
                                          color: bd().withValues(alpha: 0.1)),
                                      child: CodePreview(
                                        url: previewCodeUrl ?? "",
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  );
                })));
  }
}
