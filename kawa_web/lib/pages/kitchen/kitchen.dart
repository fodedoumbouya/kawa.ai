import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/doubleValueListenable.dart';
import 'package:kawa_web/common/utils/myLog.dart';
import 'package:kawa_web/common/utils/network/dio.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/core/productUpdateListener/projectUpdateListener.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/model/generated/appPath.dart';
import 'package:kawa_web/model/generated/gitResponse.dart';
import 'package:kawa_web/model/generated/project.dart';
import 'package:kawa_web/pages/chat/chat.dart';
import 'package:kawa_web/pages/codePreview/codePreview.dart';
import 'package:kawa_web/pages/globalSettings/globalSettings.dart';
import 'package:kawa_web/pages/phone/phoneView.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';
import 'package:collection/collection.dart';

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
  final _appPaths = ValueNotifier<List<AppPath>?>(null);
  final _loading = ValueNotifier<bool>(false);
  final project = ValueNotifier<Project?>(null);
  final _host = ValueNotifier<String?>(null);
  final _processRunningStoping =
      ValueNotifier<bool>(false); // check if the process is running
  final _isServerRunning =
      ValueNotifier<bool>(false); // check if the server is running
  final _selectedPath =
      ValueNotifier<String?>(null); // check if the app path is selected
  final TextEditingController _chatController = TextEditingController();
  String? designReference;
  final _canUndoRedoStatus =
      ValueNotifier<GitResponse>(GitResponse(success: false));
  String? previewCodeUrl;

  getAppPath(String routers) async {
    _appPaths.value = null;
// routers: {exercise_detail: /workouts/:workoutId/exercises/:exerciseId, exercise_list: /workouts/:workoutId/exercises, home: /, login: /login, progress_tracker: /progress, settings: /settings, signup: /signup, workout_detail: /workouts/:workoutId, workout_list: /workouts}
// convert to json
    // Extract just the content inside the curly braces
    final pattern = RegExp(r'{(.*)}');
    final match = pattern.firstMatch(routers);
    final contentInside = match?.group(1) ?? "";
    // print("routers: $routers");

    // Split by comma to get key-value pairs
    final pairs = contentInside.split(", ");

    // Create the map
    final Map<String, String> routersMap = {};

    for (var pair in pairs) {
      final keyValue = pair.split(": ");
      if (keyValue.length == 2) {
        routersMap[keyValue[0]] = keyValue[1];
      }
    }
    try {
      final bodyJson = routersMap;
      print("bodyJson: $bodyJson");
      for (var path in bodyJson.entries) {
        String p = path.value;
        if (p.contains("/:")) {
          p = "${p.replaceAll("/:", "?")}=1";
        }
        print("path: $p");
        final isSelected = p == "/login" ? true : false;
        final appPath = AppPath(
            id: getUniqueID(), name: path.key, path: p, isSelected: isSelected);
        _appPaths.value ??= [];
        _appPaths.value!.add(appPath);
        if (isSelected) {
          _selectedPath.value = p;
        }
        // print("appPath: $appPath");
      }
      _selectedPath.value ??= _appPaths.value
          ?.firstWhereOrNull(
              (element) => element.path.trim().toLowerCase() == "/")
          ?.path;
      _selectedPath.value ??= _appPaths.value?.first.path;
    } catch (e) {
      AppLog.e("Error: $e");
      _appPaths.value = [];
    }
  }

  getProject() async {
    _loading.value = true;
    project.value = await UserManagement.getProject(widget.projectId);
    _host.value = await UserManagement.getProjectHost(widget.projectId);
    _isServerRunning.value = await DioUtil.isServerRunning(_host.value);
    // project.value.projectStructure
    getAppPath(project.value?.routers ?? "");
    _loading.value = false;
    List<dynamic>? projectInitPrompt =
        project.value?.projectStructure["nextAgent"]["frontEnd"]["screen"];
    designReference = project.value?.projectStructure["nextAgent"]["frontEnd"]
        ["designReference"];
    for (var element in projectInitPrompt ?? []) {
      // print("element: $element");
      final m = element as Map<String, dynamic>;
      addInitPrompt(m);
    }
  }

  void addInitPrompt(Map<String, dynamic> m) {
    for (var i = 0; i < (_appPaths.value ?? []).length; i++) {
      final path = _appPaths.value?[i];
      for (var key in m.keys) {
        // print("name: ${path?.name} key: $key");
        if ((key.toLowerCase()).contains((path?.name ?? "").toLowerCase())) {
          // print("contains: ${path?.name} key: $key");
          _appPaths.value?[i].initPrompt = m[key];
        }
      }
    }
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
    ProjectUpdateListener.streamController.stream.listen((event) async {
      final data = jsonDecode(event);
      if (data["code"] == "0") {
        final hotReloadScreen = data["screen"] as String?;
        if (_selectedPath.value == "/") {
          _selectedPath.value = "home";
        }
        _selectedPath.value = _selectedPath.value?.replaceAll("/", "");
        if (((hotReloadScreen != null && _selectedPath.value != null) &&
            (hotReloadScreen).contains(_selectedPath.value ?? ""))) {
          webviewController?.reload();
        }
        getUndoRedoStatus();
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _appPaths.dispose();
    project.dispose();
    _host.dispose();
    _processRunningStoping.dispose();
    _isServerRunning.dispose();
    _selectedPath.dispose();
    showCodePreview.dispose();
    _canUndoRedoStatus.dispose();
    webviewController?.dispose();
    previewCodeUrl = null;
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
          urlRequest: URLRequest(
              url: WebUri(
                  "${_host.value}${_appPaths.value?.firstWhere((element) => element.isSelected).path}")),
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
    String currentScreen;
    if (_selectedPath.value == "/") {
      currentScreen = "home";
    }
    currentScreen = _selectedPath.value?.replaceAll("/", "") ?? "";

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
                                  Spacer(),
                                  ValueListenableBuilder(
                                      valueListenable: _appPaths,
                                      builder: (context, value, child) {
                                        if (value == null || value.isEmpty) {
                                          return SizedBox(
                                            width: 45.h,
                                            height: 50,
                                          );
                                        }
                                        AppPath? selectedPath =
                                            value.firstWhereOrNull(
                                          (element) => element.isSelected,
                                        );
                                        selectedPath ??= value.firstWhereOrNull(
                                          (element) =>
                                              element.path ==
                                              _selectedPath.value,
                                        );

                                        return CustomContainer(
                                          w: 15.h,
                                          h: 50,
                                          border: Border.all(
                                              color:
                                                  bd().withValues(alpha: 0.1)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: CustomDropdown(
                                            items: value,
                                            initialItem: selectedPath,
                                            visibility: (visi) {},
                                            headerBuilder: (context,
                                                selectedItem, enabled) {
                                              return CustomTextWidget(
                                                selectedItem.name,
                                                size: 9.sp,
                                                color: bd(),
                                                fontWeight: FontWeight.bold,
                                              );
                                            },
                                            decoration:
                                                CustomDropdownDecoration(
                                              closedFillColor:
                                                  Colors.transparent,
                                            ),
                                            listItemBuilder: (context, item,
                                                isSelected, onItemSelect) {
                                              return CustomTextWidget(
                                                item.name,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : bd(),
                                                size: 9.sp,
                                              );
                                            },
                                            onChanged: (p0) {
                                              for (var element in value) {
                                                element.isSelected = false;
                                                if (element.id == p0?.id) {
                                                  element.isSelected = true;
                                                }
                                              }

                                              if (p0?.path !=
                                                  _selectedPath.value) {
                                                _selectedPath.value = p0?.path;

                                                /// load the selected path
                                                webviewController?.loadUrl(
                                                    urlRequest: URLRequest(
                                                  url: WebUri(
                                                      "${_host.value}${p0?.path}"),
                                                ));
                                              }
                                            },
                                          ),
                                        );
                                      }),
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
                                  CustomTextWidget("Project Settings Keys"),
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
                                                    final tmp =
                                                        List<AppPath>.from(
                                                            _appPaths.value ??
                                                                []);
                                                    String? found;
                                                    for (var i = 0;
                                                        i < tmp.length;
                                                        i++) {
                                                      final path = tmp[i];
                                                      final webPath =
                                                          src.split("/").last;
                                                      final pathUrl = path.path
                                                          .split("/")[1];
                                                      if (webPath == pathUrl) {
                                                        path.isSelected = true;
                                                        found = path.path;
                                                      } else {
                                                        path.isSelected = false;
                                                      }
                                                    }
                                                    if (found != null) {
                                                      _selectedPath.value =
                                                          found;
                                                      _appPaths.value = tmp;
                                                    }
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
                                    if (!value)
                                      CustomContainer(
                                          h: 100.h,
                                          w: sizeLeft,
                                          border: Border.all(
                                              color:
                                                  bd().withValues(alpha: 0.1)),
                                          child: ValueListenableBuilderDouble(
                                            first: _host,
                                            second: _selectedPath,
                                            builder: (context, value,
                                                selectionApp, child) {
                                              final selectPrompt = _appPaths
                                                  .value
                                                  ?.firstWhereOrNull(
                                                      (element) =>
                                                          element.path ==
                                                          selectionApp)
                                                  ?.initPrompt;
                                              print(
                                                  "selectPrompt: $selectPrompt");
                                              return GlobalSettings(
                                                host: value,
                                                initPrompt: selectPrompt,
                                                globalInitPrompt:
                                                    designReference,
                                                onInitPromptClick:
                                                    (isGlobalInitPrompt) {
                                                  if (_chatController
                                                      .text.isEmpty) {
                                                    _chatController.text =
                                                        (isGlobalInitPrompt
                                                                ? designReference
                                                                : selectPrompt) ??
                                                            "";
                                                  } else {
                                                    _chatController.text =
                                                        "${_chatController.text}\n${(isGlobalInitPrompt ? designReference : selectPrompt) ?? ""}";
                                                  }
                                                },
                                              );
                                            },
                                          )),
                                    if (value)
                                      CustomContainer(
                                        h: 100.h,
                                        w: 100.w - 47.h,
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
