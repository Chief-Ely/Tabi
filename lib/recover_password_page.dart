import 'package:tabi/change_notifier/registration_controller.dart';
import 'package:tabi/core/validator.dart';
import 'package:tabi/widgets/icon_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/form_field.dart' as custom;
import 'widgets/button.dart' as custom;

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  late final TextEditingController emailController;

  GlobalKey<FormFieldState> emailKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconBackButton(),
        title: Text('Recover Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dont\'t worry! Happens to the best of us!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              custom.FormField(
                controller: emailController,
                key: emailKey,
                fillColor: theme.colorScheme.surface,
                filled: true,
                labelText: 'Email',
                validator: Validator.emailValidator,
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: Selector<RegistrationController, bool>(
                  selector: (_, controller) => controller.isLoading,
                  builder: (_, isLoading, __) => custom.Button(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (emailKey.currentState?.validate() ?? false) {
                              context
                                  .read<RegistrationController>()
                                  .resetPassword(
                                    context: context,
                                    email: emailController.text.trim(),
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
                        : Text('Send me a recovery link!'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
