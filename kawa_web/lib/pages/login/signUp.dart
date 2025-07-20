import 'package:flutter/material.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class SignUp extends BaseWidget {
  const SignUp({super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _SignUpState();
  }
}

class _SignUpState extends BaseWidgetState<SignUp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _showPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _showPassword.dispose();
    super.dispose();
  }

  void _createUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final resp = await UserManagement.signUpUser(
        email: email, password: password, passwordConfirm: confirmPassword);

    if (resp) {
      CoreToast.showSuccess("User created successfully");
      await Future.delayed(const Duration(seconds: 2));
      AppNavigator.goLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bc(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.app_shortcut,
                  size: 32,
                  color: bd().withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                CustomTextWidget(
                  'Kawa AI',
                  size: 32,
                  fontWeight: FontWeight.bold,
                  color: bd().withValues(alpha: 0.9),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: bd().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomTextWidget(
                    'beta',
                    size: 12,
                    color: bd().withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextWidget(
              'Create your account to get started',
              size: 20,
              color: bd().withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // spacing: 5,
                children: [
                  CustomTextWidget("Email Address",
                      size: 16,
                      color: bd().withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextWidget("Password",
                      size: 16,
                      color: bd().withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _showPassword,
                    builder: (context, value, child) {
                      return CustomTextField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: value,
                        showSuffixIcon: true,
                        onPressed: () =>
                            _showPassword.value = !_showPassword.value,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextWidget("Confirm Password",
                      size: 16,
                      color: bd().withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ConfirmButton(
                txt: "Sign Up",
                bColor: KColors.bcBlue,
                txtSize: 10,
                width: 900,
                elevation: 0,
                radius: 3,
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty) {
                    CoreToast.showError("All fields are required");
                    return;
                  }
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    CoreToast.showError("Passwords do not match");
                    return;
                  }
                  // email and password are valid
                  if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(_emailController.text)) {
                    _createUser();
                  } else {
                    CoreToast.showError("Invalid email address");
                  }
                }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
