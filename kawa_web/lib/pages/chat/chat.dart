import 'package:flutter/material.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/model/chatMessage.dart';
import 'package:kawa_web/pages/chat/widgets/kawaTextField.dart';

import 'histories/histories.dart';

class Chat extends BaseWidget {
  final String projectId;
  final dynamic Function(String) onSubmitted;
  final TextEditingController controller;
  const Chat(
      {required this.projectId,
      required this.controller,
      required this.onSubmitted,
      super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _ChatState();
  }
}

class _ChatState extends BaseWidgetState<Chat> {
  final messages = ValueNotifier<List<ChatMessage>>(([]));

  Future<void> messageManager() async {
    UserManagement.subscribeToMessages(widget.projectId, (p0) {
      //update delete create
      if (p0.action == "create") {
        final message = ChatMessage(
          id: p0.record?.id ?? "",
          text: p0.record?.data["content"] ?? "",
          isUser: p0.record?.data["role"] == "user",
          created: DateTime.parse(p0.record?.data["created"] ?? ""),
          updated: DateTime.parse(p0.record?.data["updated"] ?? ""),
        );
        messages.value = [...messages.value, message];
      } else if (p0.action == "update") {
        // Handle update
        final index =
            messages.value.indexWhere((message) => message.id == p0.record?.id);
        if (index != -1) {
          messages.value[index] = ChatMessage(
            id: p0.record?.id ?? "",
            text: p0.record?.data["content"] ?? "",
            isUser: p0.record?.data["role"] == "user",
            created: DateTime.parse(p0.record?.data["created"] ?? ""),
            updated: DateTime.parse(p0.record?.data["updated"] ?? ""),
          );
        }
      } else if (p0.action == "delete") {
        // Handle delete
        messages.value.removeWhere(
          (element) => element.id == p0.record?.id,
        );
      }
      messages.notifyListeners();
    });
  }

  getAllTheMessages() async {
    final messagesList = await UserManagement.getAllMessages(widget.projectId);
    messages.value = messagesList;
  }

  @override
  void initState() {
    // Get all the messages
    getAllTheMessages();
    messageManager();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
          valueListenable: messages,
          builder: (context, value, child) {
            return HistoriesChat(
              messages: value,
            );
          },
        )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.sp),
          child: KawaTextField(
              onSubmitted: widget.onSubmitted, controller: widget.controller),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
