import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class KawaTextField extends BaseWidget {
  final Function(String) onSubmitted;
  final String hintText;
  final TextEditingController controller;

  const KawaTextField({
    super.key,
    required this.onSubmitted,
    this.hintText = 'Build your kawa app...',
    required this.controller,
  });

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _KawaTextFieldState();
  }
}

class _KawaTextFieldState extends BaseWidgetState<KawaTextField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _hasText = widget.controller.text.trim().isNotEmpty;
    rebuildState();
  }

  void _handleSubmit() {
    CoreToast.showInfo("Feature under development");
  }

  @override
  Widget build(BuildContext context) {
    final bd = Theme.of(context).colorScheme.primaryContainer;
    final bp = Theme.of(context).primaryColor;
    // final bc = Theme.of(context).colorScheme.primary;
    return CustomContainer(
      color: bp,
      border: Border.all(color: bd.withValues(alpha: 0.2), width: 1),
      borderRadius: BorderRadius.circular(KConstant.radius),
      allP: 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 5,
        children: [
          SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
            child: IconButton(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.file_copy),
              color: bd.withValues(alpha: 0.7),
              splashRadius: 20,
            ),
          ),
          Expanded(
            child: CustomContainer(
              color: bp,
              border: Border.all(color: bd.withValues(alpha: 0.2), width: 1),
              borderRadius: BorderRadius.circular(KConstant.radius),
              child: TextField(
                controller: widget.controller,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.openSans(
                    color: bd.withValues(alpha: 0.5),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.openSans(color: bd),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onSubmitted(widget.controller.text.trim());
                    widget.controller.clear();
                  }
                },
              ),
            ),
          ),
          CustomContainer(
            color: bd.withValues(alpha: _hasText ? 1 : 0.2),
            leftM: 4.0,
            rightM: 4.0,
            bottomM: 4.0,
            borderRadius: BorderRadius.circular(KConstant.radius),
            child: IconButton(
              onPressed: () {
                if (_hasText) {
                  widget.onSubmitted(widget.controller.text.trim());
                  widget.controller.clear();
                }
              },
              icon: const Icon(Icons.send),
              color: bp,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}
