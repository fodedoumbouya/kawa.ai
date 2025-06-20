part of 'custom.dart';

class LoadingView {
  BuildContext context;
  // static final LoadingView singleton = LoadingView._();

  // factory LoadingView() => singleton;
  Color? bgColor;

  LoadingView({required this.context, this.bgColor});

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  Future<T> wrap<T>({required Future<T> Function() asyncFunction}) async {
    show();
    T data;
    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      rethrow;
    } finally {
      dismiss();
    }
    return data;
  }

  void show() async {
    if (_isVisible) return;
    _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        color: bgColor ??
            Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.2),
        child: Center(
          child: SpinKitCircle(
            size: 35,
            color: Colors.blue,
            // ZColors.bc,
          ),
        ),
      ),
    );
    _isVisible = true;
    if (!context.mounted) return;
    _overlayState?.insert(_overlayEntry!);
  }

  dismiss() async {
    if (!_isVisible) return;
    _isVisible = false;
    _overlayEntry?.remove();
  }
}
