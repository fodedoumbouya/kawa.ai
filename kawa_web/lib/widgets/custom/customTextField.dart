part of 'custom.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final void Function()? onPressed;
  final bool showSuffixIcon;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
    this.onPressed,
    this.showSuffixIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final bd = Theme.of(context).colorScheme.primaryContainer;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        // hintText: hintText,
        // hintStyle: TextStyle(
        //   color: bd.withValues(alpha: 0.7),
        // ),
        suffixIcon: showSuffixIcon == false
            ? null
            : IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: bd.withValues(alpha: 0.7),
                ),
                onPressed: onPressed,
              ),
        filled: true,
        fillColor: bd.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(3),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}
