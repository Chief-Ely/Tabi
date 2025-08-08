import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'change_notifier/registration_controller.dart';

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
  late final String _emailPattern;

  @override
  void initState() {
    super.initState();
    registrationController = context.read();

    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    formKey = GlobalKey<FormState>();

    _emailPattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
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
                          fillColor: theme.dialogBackgroundColor,
                          filled: true,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          validator: (name) {
                            name = name?.trim() ?? '';

                            return name.isEmpty ? 'No name provided!' : null;
                          },
                          onChanged: (newValue) {
                            registrationController.userName = newValue;
                          },
                        ),
                        SizedBox(height: 8),
                      ],
                      custom.FormField(
                        controller: emailController,
                        labelText: 'Email Address',
                        fillColor: theme.dialogBackgroundColor,
                        filled: true,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (email) {
                          email = email?.trim() ?? '';

                          return email.isEmpty
                              ? 'No email provided!'
                              : !RegExp(_emailPattern).hasMatch(email)
                              ? 'Password is not in a valid format!'
                              : null;
                        },
                        onChanged: (newValue) {
                          registrationController.email = newValue;
                        },
                      ),
                      SizedBox(height: 8),
                      Selector<RegistrationController, bool>(
                        selector: (_, controller) =>
                            controller.isPasswordHidden,
                        builder: (context, isPasswordHidden, _) => custom.FormField(
                          controller: passwordController,
                          labelText: 'Password',
                          fillColor: Theme.of(context).dialogBackgroundColor,
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
                          validator: (password) {
                            String errorMessage = '';
                            password = password?.trim() ?? '';

                            if (password.isEmpty) {
                              errorMessage = 'No password provided!';
                            } else {
                              if (password.length < 6) {
                                errorMessage +=
                                    '\nPassword must be at least 6 characters long!';
                              }
                              if (!password.contains(RegExp(r'[a-z]'))) {
                                errorMessage +=
                                    '\nPassword must contain at least one lowercase letter!';
                              }
                              if (!password.contains(RegExp(r'[A-Z]'))) {
                                errorMessage +=
                                    '\nPassword must contain at least one uppercase letter!';
                              }
                              if (!password.contains(RegExp(r'[0-9]'))) {
                                errorMessage +=
                                    '\nPassword must contain at least one number!';
                              }
                            }
                            return errorMessage.isNotEmpty
                                ? errorMessage.trim()
                                : null;
                          },
                          onChanged: (newValue) {
                            registrationController.password = newValue;
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      if (!isRegisterMode) ...[
                        Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
                                  if (formKey.currentState?.validate() ?? false) {
                                    // Temporary test login logic
                                    if(isRegisterMode){
                                      _testLogin(context, isRegistering: true); // 👈 register mode
                                    }
                                    else{
                                      _testLogin(context, isRegistering: false); // 👈 login mode
                                    }

                                    // 🔒 Original login logic (commented out for now)
                                    // registrationController
                                    //     .authenticateWithEmailAndPassword(
                                    //         context: context,
                                    //     );
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
                              onPressed: () {},
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

//   //Use to bypass for test purposes only
//   void _testLogin(BuildContext context) {
//   final email = emailController.text.trim();
//   final password = passwordController.text.trim();

//   if (email == 'law@gmail.com' && password == 'Password123456') {
//     Navigator.pushReplacementNamed(context, '/dashboard');
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Test login failed')),
//     );
//   }
// }
// void _testLogin(BuildContext context) async {
//   final username = userNameController.text.trim();
//   final email = emailController.text.trim();
//   final password = passwordController.text.trim();

//   // Open or create Hive box
//   var box = await Hive.openBox('users');

//   // Check if email already registered
//   final existingUser = box.get(email);

//   if (existingUser == null) {
//     // 📝 Store new user
//     await box.put(email, {
//       'username': username,
//       'email': email,
//       'password': password,
//     });

//     // ✅ Show registration success
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Registration successful! You are now logged in.')),
//     );

//     // You can navigate to login page or dashboard if needed
//     Navigator.pushReplacementNamed(context, '/dashboard');
//   } else {
//     // 🔒 Try to login
//     if (existingUser['password'] == password) {
//       // ✅ Login success
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login successful. Welcome ${existingUser['username']}!')),
//       );

//       // You can navigate to dashboard/home here
//       Navigator.pushReplacementNamed(context, '/dashboard');
//     } else {
//       // ❌ Incorrect password
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Incorrect password.')),
//       );
//     }
//   }
// }
Future<void> _testLogin(BuildContext context, {required bool isRegistering}) async {
  final username = userNameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  var box = await Hive.openBox('users');
  final existingUser = box.get(email);

  if (isRegistering) {
    // 📌 Reject if email already exists
    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email is already registered! Please log in.')),
      );
      return;
    }

    // ✅ Store new user
    await box.put(email, {
      'username': username,
      'email': email,
      'password': password,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration successful! Welcome $username.')),
    );
    Navigator.pushReplacementNamed(context, '/dashboard');

  } else {
    // 📌 Reject if account does not exist
    if (existingUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No account found for this email. Please register.')),
      );
      return;
    }

    // 📌 Check password
    if (existingUser['password'] == password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful. Welcome ${existingUser['username']}!')),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect password.')),
      );
    }
  }
}




}
