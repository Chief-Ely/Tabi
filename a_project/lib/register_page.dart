import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:tabi/change_notifier/registration_controller.dart';
import 'package:tabi/core/validator.dart';
import 'package:tabi/recover_password_page.dart';

import 'widgets/form_field.dart' as custom;
import 'widgets/button.dart' as custom;
import 'widgets/icon_button_outlined.dart' as custom;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegistrationController registrationController;

  late final TextEditingController userNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    registrationController = context.read();

    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Selector<RegistrationController, bool>(
                selector: (_, controller) => controller.isRegisterMode,
                builder: (_, isRegisterMode, __) => Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isRegisterMode ? 'Register' : 'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'In order to sync your data through the cloud, you have to register/login in to the app.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48),
                      if (isRegisterMode) ...[
                        custom.FormField(
                          controller: userNameController,
                          labelText: 'Username',
                          fillColor: theme.colorScheme.surface,
                          filled: true,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          validator: Validator.userNameValidator,
                        ),
                        SizedBox(height: 8),
                      ],
                      custom.FormField(
                        controller: emailController,
                        labelText: 'Email Address',
                        fillColor: theme.colorScheme.surface,
                        filled: true,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validator.emailValidator,
                      ),
                      SizedBox(height: 8),
                      Selector<RegistrationController, bool>(
                        selector: (_, controller) =>
                            controller.isPasswordHidden,
                        builder: (context, isPasswordHidden, _) =>
                            custom.FormField(
                              controller: passwordController,
                              labelText: 'Password',
                              fillColor: theme.colorScheme.surface,
                              filled: true,
                              obscureText: isPasswordHidden,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  registrationController.isPasswordHidden =
                                      !isPasswordHidden;
                                },
                                child: Icon(
                                  isPasswordHidden
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                ),
                              ),
                              validator: Validator.passwordValidator,
                            ),
                      ),
                      SizedBox(height: 12),
                      if (!isRegisterMode) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecoverPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      SizedBox(
                        height: 48,
                        child: Selector<RegistrationController, bool>(
                          selector: (_, controller) => controller.isLoading,
                          builder: (_, isLoading, __) => custom.Button(
                            onPressed: isLoading
                                ? null
                                : () {
                                    registrationController.userName =
                                        userNameController.text;
                                    registrationController.email =
                                        emailController.text;
                                    registrationController.password =
                                        passwordController.text;

                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      registrationController
                                          .authenticateWithEmailAndPassword(
                                            context: context,
                                          );
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.surface,
                                    ),
                                  )
                                : Text(
                                    isRegisterMode
                                        ? 'Create my account'
                                        : 'Log me in',
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              isRegisterMode
                                  ? 'Or register with'
                                  : 'Or sign in with',
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: custom.IconButtonOutlined(
                              icon: FontAwesomeIcons.google,
                              onPressed: () {
                                registrationController.authenticateWithGoogle(
                                  context: context,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: custom.IconButtonOutlined(
                              icon: FontAwesomeIcons.facebook,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text.rich(
                        TextSpan(
                          text: isRegisterMode
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          children: [
                            TextSpan(
                              text: isRegisterMode ? 'Sign in' : 'Register',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  registrationController.isRegisterMode =
                                      !isRegisterMode;
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
