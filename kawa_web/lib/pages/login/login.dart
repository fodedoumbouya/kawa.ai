import 'package:flutter/material.dart';
import 'package:kawa_web/base/baseStateNotifier.dart';
import 'package:kawa_web/base/baseWidget.dart';
import 'package:kawa_web/base/repo/user/logic.dart';
import 'package:kawa_web/common/router/appNavigator.dart';
import 'package:kawa_web/common/router/appRoutes.dart';
import 'package:kawa_web/common/utils/style/colors.dart';
import 'package:kawa_web/core/creatingProjectListener/creatingProjectListener.dart';
import 'package:kawa_web/core/userManagement/userManagement.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:kawa_web/widgets/custom/custom.dart';

class Login extends BaseWidget {
  const Login({super.key});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _LoginState();
  }
}

class _LoginState extends BaseWidgetState<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _showPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _showPassword.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final resp =
        await UserManagement.loginUser(email: email, password: password);

    if (resp != null) {
      CoreToast.showSuccess("User logged in successfully");
      (userProvider.getFunction(ref) as UserNotifier).setUser(resp);
      CreatingProjectListener.instance.initialize();
      await Future.delayed(const Duration(seconds: 1));

      AppNavigator.clearAndNavigate(AppRoutes.home);
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
              'Sign in to your account',
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomTextWidget("Forgot Password?",
                size: 16,
                color: bd().withValues(alpha: 0.7),
                fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            ConfirmButton(
                txt: "Sign In",
                bColor: KColors.bcBlue,
                txtSize: 13,
                width: 900,
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    CoreToast.showError("All fields are required");
                    return;
                  }
                  // email and password are valid
                  if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(_emailController.text)) {
                    _login();
                  } else {
                    CoreToast.showError("Invalid email address");
                  }
                }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget("Don't have an account?",
                    size: 16,
                    color: bd().withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    AppNavigator.goSignUp();
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: CustomTextWidget("Sign Up",
                        size: 16,
                        color: KColors.bcBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
