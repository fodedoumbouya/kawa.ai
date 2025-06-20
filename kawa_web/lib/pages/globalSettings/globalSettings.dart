import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class GlobalSettings extends BaseWidget {
  final String? host;
  final String? initPrompt;
  final String? globalInitPrompt;
  final void Function(bool)? onInitPromptClick;
  const GlobalSettings(
      {this.host,
      this.initPrompt,
      this.onInitPromptClick,
      this.globalInitPrompt,
      super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _GlobalSettingsState();
  }
}

class SettingValue {
  String key;
  String value;
  bool onSubmitted;
  bool canEdit;
  bool addApplyBtt;
  SettingValue({
    required this.key,
    required this.value,
    this.onSubmitted = false,
    this.canEdit = true,
    this.addApplyBtt = false,
  });

  @override
  String toString() {
    return 'SettingValue(key: $key, value: $value, onSubmitted: $onSubmitted , canEdit: $canEdit)';
  }
}

class _GlobalSettingsState extends BaseWidgetState<GlobalSettings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  final screenSettings = ValueNotifier<List<SettingValue>>([]);
  final globalSettings = ValueNotifier<List<SettingValue>>([]);
  String? initPrompt;
  String? globalInitPrompt;

  @override
  void initState() {
    initPrompt = widget.initPrompt;
    globalInitPrompt = widget.globalInitPrompt;
    if (widget.host != null) {
      globalSettings.value.add(
        SettingValue(
            key: "HOST URL",
            value: widget.host ?? "",
            onSubmitted: true,
            canEdit: false),
      );
    }
    globalSettings.value.add(
      SettingValue(
          key: "GLOBAL INITIAL PROMPT",
          value: widget.globalInitPrompt ?? "",
          onSubmitted: true,
          addApplyBtt: true),
    );

    screenSettings.value.add(
      SettingValue(
          key: "SCREEN INITIAL PROMPT",
          value: widget.initPrompt ?? "",
          onSubmitted: true,
          addApplyBtt: true),
    );

    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GlobalSettings oldWidget) {
    if (oldWidget.initPrompt != widget.initPrompt) {
      screenSettings.value[0].value = widget.initPrompt ?? "";
      screenSettings.notifyListeners();
    }
    if (oldWidget.globalInitPrompt != widget.globalInitPrompt) {
      globalSettings.value[1].value = widget.globalInitPrompt ?? "";
      globalSettings.notifyListeners();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: CustomContainer(
                border: Border(
                  bottom: BorderSide(color: bd().withValues(alpha: 0.1)),
                ),
                allP: 5,
                allM: 5,
                borderRadius: BorderRadius.circular(KConstant.radius),
                color: bp(),
                child: TabBar(
                  controller: _tabController,
                  onTap: (value) {
                    _tabIndex = value;
                  },
                  tabs: const [
                    Tab(text: 'Screen Settings'),
                    Tab(text: 'Global Settings'),
                  ],
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(KConstant.radius),
                    color: bc(),
                    border: Border.all(color: bd().withValues(alpha: 0.1)),
                  ),
                  labelColor: Colors.blue,
                  unselectedLabelColor: bd(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelStyle: GoogleFonts.openSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_tabIndex == 0) {
                  screenSettings.value.add(SettingValue(key: '', value: ''));
                  screenSettings.notifyListeners();
                } else {
                  globalSettings.value.add(SettingValue(key: '', value: ''));
                  globalSettings.notifyListeners();
                }
              },
              child: CustomContainer(
                allM: 5,
                allP: 5,
                h: 50,
                w: 50,
                mouseRegion: true,
                border: Border.all(color: bd().withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(KConstant.radius),
                child: Icon(Icons.add, size: 15.sp),
              ),
            ),
            SizedBox.shrink(),
          ],
        ),
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: ValueListenableBuilder(
                valueListenable: screenSettings,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ...value.map((setting) {
                        return _buildSettingSection(
                          setting: setting,
                          onSubmittedValueChange: () {
                            screenSettings.notifyListeners();
                          },
                          onDelete: () {
                            screenSettings.value.remove(setting);
                            screenSettings.notifyListeners();
                          },
                          onSubmitted: () {
                            setting.onSubmitted = true;
                            screenSettings.notifyListeners();
                          },
                          onInitPromptClick: () {
                            if (widget.onInitPromptClick != null) {
                              widget.onInitPromptClick!(false);
                              setting.addApplyBtt = false;
                              screenSettings.notifyListeners();
                              Future.delayed(
                                const Duration(seconds: 1),
                                () {
                                  if (!mounted) return;
                                  setting.addApplyBtt = true;
                                  screenSettings.notifyListeners();
                                },
                              );
                            }
                          },
                        );
                      }),
                    ],
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: ValueListenableBuilder(
                valueListenable: globalSettings,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      ...List.generate(
                        value.length,
                        (index) {
                          final setting = value[index];
                          return _buildSettingSection(
                            setting: setting,
                            onSubmittedValueChange: () {
                              globalSettings.notifyListeners();
                            },
                            onInitPromptClick: () {
                              if (widget.onInitPromptClick != null) {
                                widget.onInitPromptClick!(true);
                                setting.addApplyBtt = false;
                                globalSettings.notifyListeners();
                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () {
                                    if (!mounted) return;
                                    setting.addApplyBtt = true;
                                    globalSettings.notifyListeners();
                                  },
                                );
                              }
                            },
                            onDelete: () {
                              globalSettings.value.remove(setting);
                              globalSettings.notifyListeners();
                            },
                            onSubmitted: () {
                              globalSettings.value[index].onSubmitted = true;
                              globalSettings.notifyListeners();
                            },
                          );
                        },
                      )
                    ],
                  );
                }),
          ),
        ]))
      ],
    );
  }

  Widget _buildSettingSection({
    required SettingValue setting,
    required void Function() onSubmittedValueChange,
    required void Function() onSubmitted,
    required void Function() onDelete,
    void Function()? onInitPromptClick,
  }) {
    return IgnorePointer(
      ignoring: !setting.canEdit,
      child: CustomContainer(
        border: Border.all(color: bd().withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(KConstant.radius),
        allP: 15,
        color: bc(),
        child: Column(
          spacing: 10,
          children: [
            Row(
              children: [
                CustomTextWidget(
                  "Setting",
                  size: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(width: 5),
                Icon(Icons.info, size: 11.sp),
                Spacer(),
                CustomTextWidget(
                  "Feature is under development",
                  size: 9.sp,
                  color: KColors.bcYellow,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            Row(
              children: [
                CustomTextWidget("KEY_REFERENCE:",
                    size: 11.sp, color: bcGrey(), fontWeight: FontWeight.w600),
                SizedBox(width: 10),
                Expanded(
                  child: IgnorePointer(
                    ignoring: setting.addApplyBtt,
                    child: CustomContainer(
                      color: bc(),
                      borderRadius: BorderRadius.circular(KConstant.radius),
                      w: 20.w,
                      border: Border.all(color: bd().withValues(alpha: 0.1)),
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: TextEditingController(text: setting.key)
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: setting.key.length)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter key',
                          hintStyle: GoogleFonts.openSans(
                            fontSize: 11.sp,
                            color: bd().withValues(alpha: 0.5),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != setting.key) {
                            if (setting.onSubmitted) {
                              setting.onSubmitted = false;
                              onSubmittedValueChange();
                            }
                          }
                          setting.key = value;
                        },
                        style: GoogleFonts.openSans(
                          fontSize: 11.sp,
                          color: bd(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                CustomTextWidget("KEY_VALUE:",
                    size: 11.sp, color: bcGrey(), fontWeight: FontWeight.w600),
                SizedBox(width: 10),
                Expanded(
                  child: CustomContainer(
                    color: bc(),
                    borderRadius: BorderRadius.circular(KConstant.radius),
                    w: 26.w,
                    border: Border.all(color: bd().withValues(alpha: 0.1)),
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: TextEditingController(text: setting.value)
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: setting.value.length)),
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter key value",
                        hintStyle: GoogleFonts.openSans(
                          fontSize: 11.sp,
                          color: bd().withValues(alpha: 0.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != setting.key) {
                          if (setting.onSubmitted) {
                            setting.onSubmitted = false;
                            onSubmittedValueChange();
                          }
                        }
                        setting.value = value;
                      },
                      style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        color: bd(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!setting.onSubmitted || setting.addApplyBtt) ...[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  if (setting.addApplyBtt) ...[
                    GestureDetector(
                      onTap: () {
                        if (onInitPromptClick != null) {
                          onInitPromptClick();
                        }
                      },
                      child: CustomContainer(
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(KConstant.radius),
                        allP: 5,
                        mouseRegion: true,
                        child: CustomTextWidget("Use",
                            size: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green),
                      ),
                    )
                  ],
                  if (!setting.onSubmitted) ...[
                    GestureDetector(
                      onTap: onDelete,
                      child: CustomContainer(
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(KConstant.radius),
                        allP: 5,
                        mouseRegion: true,
                        child: CustomTextWidget("Delete",
                            size: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                    ),
                    GestureDetector(
                      onTap: onSubmitted,
                      child: CustomContainer(
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(KConstant.radius),
                        allP: 5,
                        mouseRegion: true,
                        child: CustomTextWidget("Save",
                            size: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
