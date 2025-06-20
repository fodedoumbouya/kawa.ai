import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/common/utils/myLog.dart';
import 'package:kawa_web/common/utils/network/dio.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/model/generated/apiSettingModel.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';
import 'package:collection/collection.dart';

class APISettingKey extends StatefulWidget {
  const APISettingKey({super.key});

  @override
  State<APISettingKey> createState() => _APISettingKeyState();
}

class _APISettingKeyState extends State<APISettingKey> {
  final apiSettingModeList = ValueNotifier<List<ApiSettingModel>?>(null);
  final selectedModel = ValueNotifier<ApiSettingModel?>(null);
  final TextEditingController _apiController = TextEditingController();

  getApiSettingModel() async {
    apiSettingModeList.value = null;
    try {
      final resp = await DioUtil.get(url: "/supportApiSetting");
      apiSettingModeList.value = [];
      if (resp.statusCode == 200) {
        final data = resp.data as List;
        List<ApiSettingModel> apiSettingModelList = [];
        for (var i = 0; i < data.length; i++) {
          final d = data[i];
          final jsonString = jsonEncode(d);

          final apiSettingModel = ApiSettingModelMapper.fromJson(jsonString);
          apiSettingModelList.add(apiSettingModel);
        }
        apiSettingModeList.value!.addAll(apiSettingModelList);
      } else {
        CoreToast.showError("Error fetching API settings");
      }
    } catch (e) {
      CoreToast.showError("Error fetching API settings ");
      AppLog.e("Error fetching API settings: $e");
      apiSettingModeList.value = [];
    }
  }

  Widget buildTitleIcon(
      {required IconData icon, required String title, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: color,
        ),
        const SizedBox(width: 8),
        CustomTextWidget(
          title,
          size: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ],
    );
  }

  Widget divider({required Color color}) {
    return Divider(
      color: color.withValues(alpha: 0.1),
      height: 20,
      thickness: 1,
    );
  }

  @override
  void initState() {
    super.initState();
    selectedModel.value = DataPersistence.getApiSetting();
    _apiController.text = selectedModel.value?.api_key ?? "";
    getApiSettingModel();
  }

  @override
  dispose() {
    apiSettingModeList.dispose();
    selectedModel.dispose();
    _apiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = Theme.of(context).primaryColor;
    final bd = Theme.of(context).colorScheme.primaryContainer;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder(
          valueListenable: apiSettingModeList,
          builder: (context, value, child) {
            if (value == null) {
              return UiLoading(
                text: "Loading API settings...",
              );
            }

            final initialItem = value.firstWhereOrNull(
              (element) =>
                  element.model_host == selectedModel.value?.model_host,
            );
            return CustomContainer(
              w: 600,
              color: bp,
              borderRadius: BorderRadius.circular(KConstant.radius),
              padding: EdgeInsets.all(16),
              border: Border.all(
                color: bd.withValues(alpha: 0.1),
                width: 1,
              ),
              child: Column(
                children: [
                  buildTitleIcon(
                    icon: Icons.settings,
                    title: 'API Settings',
                    color: bd,
                  ),
                  CustomTextWidget(
                    "Configure Al model selection and API keys. Settings are saved automatically in your browser and are not shared with any server.",
                    withOverflow: false,
                    size: 14,
                  ),
                  const SizedBox(height: 8),
                  divider(color: bd.withValues(alpha: 0.1)),
                  const SizedBox(height: 20),
                  buildTitleIcon(
                    icon: Icons.cloud,
                    title: 'AI Host Selection',
                    color: bd,
                  ),
                  const SizedBox(height: 8),
                  CustomDropdown<ApiSettingModel>(
                    hintText: "Select AI host",
                    items: value,
                    initialItem: initialItem,
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      return CustomTextWidget(
                        item.model_host.name,
                        size: 16,
                        color: bd,
                      );
                    },
                    headerBuilder: (context, selectedItem, enabled) {
                      return CustomTextWidget(
                        selectedItem.model_host.name,
                        size: 16,
                        color: bd,
                      );
                    },
                    decoration: CustomDropdownDecoration(
                      closedBorder: Border.all(
                        color: bd.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    onChanged: (value) {
                      selectedModel.value = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  divider(color: bd.withValues(alpha: 0.1)),
                  const SizedBox(height: 20),
                  buildTitleIcon(
                    icon: Icons.settings_input_composite_outlined,
                    title: 'AI Model Selection',
                    color: bd,
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: selectedModel,
                    builder: (context, value, child) {
                      return CustomDropdown<String>(
                        hintText: "Select AI model",
                        items: value?.model_list ?? [],
                        initialItem: value?.model_name,
                        decoration: CustomDropdownDecoration(
                          closedBorder: Border.all(
                            color: bd.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        onChanged: (value) {
                          selectedModel.value?.model_name = value;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  divider(color: bd.withValues(alpha: 0.1)),
                  const SizedBox(height: 20),
                  buildTitleIcon(
                    icon: Icons.key,
                    title: 'API Key',
                    color: bd,
                  ),
                  const SizedBox(height: 8),
                  CustomContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    h: 50,
                    color: bp,
                    borderRadius: BorderRadius.circular(KConstant.radius),
                    boxShadow: [
                      BoxShadow(
                        color: bd.withValues(alpha: 0.1),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                    child: TextField(
                      cursorColor: bd,
                      style: GoogleFonts.openSans(color: bd),
                      controller: _apiController,
                      decoration: InputDecoration(
                        hintText: 'Enter your API key',
                        hintStyle: GoogleFonts.openSans(
                            color: bd.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        selectedModel.value?.api_key = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2.w,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppNavigator.goBack();
                        },
                        child: CustomContainer(
                          padding: const EdgeInsets.all(8),
                          color: bp,
                          borderRadius: BorderRadius.circular(KConstant.radius),
                          mouseRegion: true,
                          boxShadow: [
                            BoxShadow(
                              color: bd.withValues(alpha: 0.1),
                              blurRadius: 1,
                              spreadRadius: 1,
                            ),
                          ],
                          child: CustomTextWidget(
                            'Cancel',
                            size: 18,
                            fontWeight: FontWeight.bold,
                            color: bd,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (selectedModel.value == null) {
                            CoreToast.showError("Please select a model");
                            return;
                          }
                          if (selectedModel.value?.model_name == null) {
                            CoreToast.showError("Please select a model");
                            return;
                          }
                          if (selectedModel.value?.api_key == null) {
                            CoreToast.showError("Please enter an API key");
                            return;
                          }
                          DataPersistence.saveApiSetting(selectedModel.value!);
                          CoreToast.showSuccess("API settings saved");
                          AppNavigator.goBack();
                        },
                        child: CustomContainer(
                          padding: const EdgeInsets.all(8),
                          color: KColors.bcBlue.withValues(alpha: 1),
                          borderRadius: BorderRadius.circular(KConstant.radius),
                          mouseRegion: true,
                          boxShadow: [
                            BoxShadow(
                              color: bd.withValues(alpha: 0.1),
                              blurRadius: 1,
                              spreadRadius: 1,
                            ),
                          ],
                          child: CustomTextWidget(
                            'Save Settings',
                            size: 18,
                            fontWeight: FontWeight.bold,
                            color: bp,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
