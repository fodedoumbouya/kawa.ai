import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kawa_web/common/adapterHelper/responsive_sizer.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/model/chatMessage.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class HistoriesChat extends StatefulWidget {
  final List<ChatMessage> messages;

  const HistoriesChat({required this.messages, super.key});

  @override
  State<HistoriesChat> createState() => _HistoriesChatState();
}

class _HistoriesChatState extends State<HistoriesChat> {
  final _messages = ValueNotifier<List<ChatMessage>>([]);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _messages.value = widget.messages;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HistoriesChat oldWidget) {
    _messages.value = widget.messages;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        // Only auto-scroll if user is already at or near the bottom
        final double distanceToBottom =
            _scrollController.position.maxScrollExtent -
                _scrollController.offset;
        if (distanceToBottom > 150) {
          // Threshold of 150 pixels from bottom
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _messages,
      builder: (context, value, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 16, bottom: 5.h),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final message = value[index];

            return MessageBubble(message: message);
          },
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bd = Theme.of(context).colorScheme.primaryContainer;
    final bp = Theme.of(context).primaryColor;
    // final bc = Theme.of(context).colorScheme.primary;
    // the message is a model response indicating it's generating
    final bool showModelResponse =
        message.text == "--:)Genereting(53635" && !message.isUser;
    return CustomContainer(
      bottomM: 8,
      topM: 8,
      color: message.isUser ? bd.withValues(alpha: 0.1) : null,
      borderRadius: BorderRadius.circular(KConstant.radius),
      leftM: 30.sp,
      rightM: 30.sp,
      child: showModelResponse
          ? Row(
              children: [
                CustomTextWidget(
                  "Model Genereting",
                  color: bd,
                  size: 9.sp,
                  fontWeight: FontWeight.w700,
                ),
                SpinKitThreeInOut(
                  color: bd,
                  size: 12.sp,
                ),
              ],
            )
          : Markdown(
              data: message.text,
              shrinkWrap: true,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                codeblockDecoration: BoxDecoration(
                  color: bp,
                  borderRadius: BorderRadius.circular(KConstant.radius),
                  border: Border.all(color: bd.withValues(alpha: 0.1)),
                ),
                code: GoogleFonts.inter(
                  color: bd,
                  fontWeight: FontWeight.w700,
                ),
                a: GoogleFonts.inter(
                  color: bd,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
                p: GoogleFonts.inter(
                  color: bd,
                  fontSize: 10.sp,
                ),
              ),
            ),
    );
  }
}
