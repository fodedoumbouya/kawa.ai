import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/network/dio.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/model/generated/project.dart';
import 'package:kawa_web/pages/home/widgets/apiSettings/apiSettings.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

import 'utils/creatingProjectUtils.dart';

class HomePage extends BaseWidget {
  const HomePage({super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _HomePageState();
  }
}

class FeatureSectionModel {
  final String id;
  final String title;
  final IconData icon;
  final List<FeatureCardModel> cards;
  FeatureSectionStatus status;
  FeatureSectionModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.cards,
    this.status = FeatureSectionStatus.none,
  });
}

class FeatureCardModel {
  final String id;
  final String title;
  final String description;
  FeatureSectionStatus status;
  FeatureCardModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = FeatureSectionStatus.none,
  });
}

class _HomePageState extends BaseWidgetState<HomePage> {
  final isCollaped = ValueNotifier<bool>(true);
  final TextEditingController _controller = TextEditingController();
  final charactersTyped = ValueNotifier<int>(0);
  int _holderIndex = -1;
  final isGenerating = ValueNotifier<int>(-1);
  String? _projectId;
  List<Project> projects = [];
  late ProjectProgressHandler _progressHandler;

  final List<FeatureSectionModel> _listProgress = [
    FeatureSectionModel(
        id: "Creating_Project_Plan",
        title: "Create the structure",
        icon: Icons.grid_goldenratio,
        cards: [
          FeatureCardModel(
              id: "Creating_Project_Plan",
              title: "Analyze the prompt",
              description:
                  "Understand the requirements and constraints of the project"),
          FeatureCardModel(
              id: "Creating_Project_Plan",
              title: "Create the project structure plan",
              description:
                  "Create the project structure plan with all the screens and models"),
        ]),
    FeatureSectionModel(
        id: "Creating_Project",
        title: "Generate the project code",
        icon: Icons.code,
        cards: [
          FeatureCardModel(
              id: "Created_Project_Navigation_Flow",
              title: "Create the screens for the project",
              description: "Create the screens for the project"),
          FeatureCardModel(
              id: "Creating_Flutter_Project",
              title: "Create flutter project",
              description:
                  "Create the flutter project with all the screens and models"),
        ]),
    FeatureSectionModel(
        id: "Launching_Project",
        title: "Launch the project",
        icon: Icons.play_arrow,
        cards: [
          FeatureCardModel(
              id: "Project_Launched",
              title: "Launch the project",
              description:
                  "Launch the project and make the project live for the users"),
        ]),
  ];

  Future<void> generateProject({required String prompt}) async {
    try {
      final apiSetting = DataPersistence.getApiSetting();
      if (apiSetting == null) {
        CoreToast.showError("Please set your API key and host in the settings");
        return;
      }

      isGenerating.value = 0;
      // progressListener();
      final resp =
          await DioUtil.post(url: "/createProject", data: {"prompt": prompt});
      _controller.clear();

      if (resp.statusCode == 200) {
        _projectId = resp.data['projectId'];
        isGenerating.value = 1;
      } else {
        handleError(resp.statusCode == 401
            ? "Please set your API key and host in the settings"
            : "Error generating project: ${resp.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        handleError("Please set your API key and host in the settings");
      } else if (e.response?.statusCode == 400) {
        handleError(
            "Authentication failed. Please check your API key and host.");
      } else {
        handleError("Error generating project: ${e.message}");
      }
    } catch (e) {
      handleError("Error generating project: $e");
    } finally {
      rebuildState();
    }
  }

  void handleError(String message) {
    CoreToast.showError(message);
    Future.delayed(const Duration(seconds: 2), () {
      isGenerating.value = -1;
      _progressHandler.resetProgress();
      rebuildState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    charactersTyped.dispose();
    super.dispose();
  }

  initData() async {
    projects = await UserManagement.getProjects();
    rebuildState();
  }

  @override
  void initState() {
    initData();
    super.initState();
    _progressHandler = ProjectProgressHandler(_listProgress);
    _progressHandler.startListening(() => setState(() {}));
    _controller.addListener(() {
      charactersTyped.value = _controller.text.length;
    });
  }

  void deleteProject({required String projectId}) async {
    final resp = await DioUtil.deleteProject(projectId);
    if (resp) {
      CoreToast.showSuccess("Project deleted successfully");
      projects.removeWhere((project) => project.id == projectId);
      setState(() {});
    } else {
      CoreToast.showError("Error deleting project");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = getUser();
    return Scaffold(
      backgroundColor: bc(),
      body: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: isCollaped,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: value ? 0 : 250,
                decoration: BoxDecoration(
                  color: bp(),
                  border: Border(
                    right: BorderSide(
                      color: bd().withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: TapRegion(
                  onTapOutside: (event) {
                    if (!isCollaped.value) {
                      isCollaped.value = true;
                    }
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      bool isCollapsed = true;
                      if (size.width > 100 && !value) {
                        isCollapsed = false;
                      }
                      return isCollapsed
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                CustomContainer(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: bd().withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomContainer(
                                        alig: Alignment.topLeft,
                                        child: IconButton(
                                          icon: Icon(Icons.menu, color: bd()),
                                          onPressed: () => isCollaped.value =
                                              !isCollaped.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder: (context, index) {
                                    final project = projects[index];
                                    return StatefulBuilder(
                                        builder: (context, miniState) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.deferToChild,
                                        onTap: () {
                                          final apiSetting =
                                              DataPersistence.getApiSetting();
                                          if (apiSetting == null) {
                                            CoreToast.showError(
                                                "Please set your API key and host in the settings");
                                            return;
                                          }

                                          AppNavigator.goKitchen(
                                              projectID: project.id);
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onEnter: (event) {
                                            _holderIndex = index;
                                            miniState(() {});
                                          },
                                          onExit: (event) {
                                            _holderIndex = -1;
                                            miniState(() {});
                                          },
                                          child: CustomContainer(
                                            allM: 5.0,
                                            allP: 6.0,
                                            borderRadius: BorderRadius.circular(
                                                KConstant.radius),
                                            color: _holderIndex == index
                                                ? bd().withValues(alpha: 0.1)
                                                : Colors.transparent,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextWidget(
                                                    project.projectName,
                                                    size: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                CustomPopUp(
                                                  contentChild: [
                                                    ContentChild(
                                                      text: 'Open project',
                                                      icon: Icons.open_in_new,
                                                      iconColor: KColors.bcBlue,
                                                      onTap: () {
                                                        AppNavigator.goKitchen(
                                                            projectID:
                                                                project.id);
                                                      },
                                                    ),
                                                    ContentChild(
                                                      text: 'Delete project',
                                                      icon: Icons.delete,
                                                      iconColor: KColors.bcRed,
                                                      onTap: () {
                                                        deleteProject(
                                                            projectId:
                                                                project.id);
                                                      },
                                                    ),
                                                  ],
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 25,
                                                    child: Icon(
                                                        Icons.more_horiz,
                                                        color: bd().withValues(
                                                            alpha: 0.7)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                )),
                                CustomContainer(
                                    h: 5.h,
                                    w: 250,
                                    border: Border(
                                      top: BorderSide(
                                        color: bd().withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    leftM: 2.w,
                                    child: CustomTextWidget(
                                      // user?.name ?? 'User',
                                      (user?.name ?? "").isEmpty
                                          ? 'User'
                                          : user?.name ?? "",
                                      size: 16,
                                      fontWeight: FontWeight.bold,
                                      color: bd(),
                                    )),
                              ],
                            );
                    },
                  ),
                ),
              );
            },
          ),
          Expanded(
              child: ValueListenableBuilder(
            valueListenable: isGenerating,
            builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (value < 0)
                    ValueListenableBuilder(
                      valueListenable: isCollaped,
                      builder: (context, value, child) {
                        if (!value) return SizedBox(height: 40);
                        return CustomContainer(
                          alig: Alignment.topLeft,
                          h: 40,
                          child: IconButton(
                            icon: Icon(Icons.menu, color: bd()),
                            onPressed: () =>
                                isCollaped.value = !isCollaped.value,
                          ),
                        );
                      },
                    ),
                  if (value > -1)
                    SizedBox(
                      width: 500,
                      height: 100.h - 40,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 50),
                            ..._listProgress.map((e) {
                              FeatureSectionStatus status = e.status;
                              if (status == FeatureSectionStatus.loading) {
                                //  all card is done
                                status = e.cards.every((element) =>
                                        element.status ==
                                        FeatureSectionStatus.done)
                                    ? FeatureSectionStatus.done
                                    : status;
                              } else if (status == FeatureSectionStatus.none) {
                                //  check if any card is loading then set status to loading
                                status = e.cards.any((element) =>
                                        element.status ==
                                        FeatureSectionStatus.loading)
                                    ? FeatureSectionStatus.loading
                                    : status;
                                _listProgress
                                    .firstWhere(
                                      (section) => section.id == e.id,
                                      orElse: () => FeatureSectionModel(
                                          id: "",
                                          title: "",
                                          icon: Icons.abc,
                                          cards: []),
                                    )
                                    .status = status;
                              }
                              return FeatureSection(
                                  title: e.title,
                                  icon: e.icon,
                                  status: status,
                                  cards: [
                                    ...e.cards.map((e) {
                                      FeatureSectionStatus childStatus =
                                          e.status;
                                      if (status == FeatureSectionStatus.done) {
                                        childStatus = FeatureSectionStatus.done;
                                      }
                                      return FeatureCard(
                                        title: e.title,
                                        description: e.description,
                                        status: childStatus,
                                      );
                                    }),
                                  ],
                                  showConnector: true);
                            }),
                            if (value == 1) ...[
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  isGenerating.value = -1;
                                  AppNavigator.goKitchen(
                                      projectID: _projectId!);
                                },
                                child: CustomContainer(
                                  border: Border.all(
                                      color: bp().withValues(alpha: 0.7),
                                      width: 3),
                                  w: 200,
                                  padding: const EdgeInsets.all(8),
                                  borderRadius:
                                      BorderRadius.circular(KConstant.radius),
                                  color: KColors.bcBlue,
                                  mouseRegion: true,
                                  alig: Alignment.center,
                                  child: CustomTextWidget(
                                    "Let's start cooking",
                                    size: 14,
                                    color: bp(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  if (value < 0)
                    Expanded(
                      child: ChatInputTextField(
                        controller: _controller,
                        charactersTyped: charactersTyped,
                        onGenerate: () {
                          if (_controller.text.isEmpty) {
                            CoreToast.showError("Please enter a prompt");
                            return;
                          }
                          generateProject(prompt: _controller.text);
                        },
                      ),
                    ),
                ],
              );
            },
          ))
        ],
      ),
    );
  }
}

class ChatInputTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<int> charactersTyped;
  final void Function()? onGenerate;
  const ChatInputTextField(
      {required this.controller,
      required this.charactersTyped,
      this.onGenerate,
      super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Theme.of(context).primaryColor;
    final bd = Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      // color: Colors.red,
      // height: 300,
      width: 800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.app_shortcut,
                size: 32,
                color: bd.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              CustomTextWidget(
                'Kawa AI',
                size: 28,
                fontWeight: FontWeight.bold,
                color: bd.withValues(alpha: 0.9),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: bd.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomTextWidget(
                  'beta',
                  size: 12,
                  color: bd.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextWidget(
            'Describe your dream app and we\'ll bring it to life',
            size: 16,
            color: bd.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 32),
          // Input container
          CustomContainer(
            w: 600,
            padding: const EdgeInsets.all(16),
            color: bp,
            borderRadius: BorderRadius.circular(KConstant.radius),
            boxShadow: [
              BoxShadow(
                color: bd.withValues(alpha: 0.1),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  cursorColor: bd,
                  style: GoogleFonts.openSans(color: bd),
                  decoration: InputDecoration(
                    hintText: 'Describe your dream app...',
                    hintStyle: GoogleFonts.openSans(
                      color: bd.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value.isNotEmpty && onGenerate != null) {
                      onGenerate!();
                    } else {
                      CoreToast.showError("Please enter a prompt");
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.file_present_sharp,
                      size: 20,
                      color: bd.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: charactersTyped,
                      builder: (context, value, child) => CustomTextWidget(
                        '$value character${value > 1 ? 's' : ''}',
                        color: bd.withValues(alpha: 0.5),
                        size: 14,
                      ),
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: charactersTyped,
                      builder: (context, value, child) => ElevatedButton(
                        onPressed: onGenerate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (value > 0) ? bd : bp.withValues(alpha: 0.2),
                          foregroundColor: bp,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: CustomTextWidget('Generate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: APISettingKey(),
                  );
                },
              );
            },
            child: CustomContainer(
              border: Border.all(color: bd.withValues(alpha: 0.1), width: 3),
              w: 150,
              padding: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(KConstant.radius),
              color: bp,
              mouseRegion: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.settings,
                    size: 20,
                    color: bd,
                  ),
                  CustomTextWidget(
                    'API Settings Key',
                    size: 14,
                    color: bd,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
