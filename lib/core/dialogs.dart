import 'package:flutter/material.dart';

import 'package:a_project/widgets/confirmation_dialog.dart' as custom;
import 'package:a_project/widgets/message_dialog.dart' as custom;

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => custom.ConfirmationDialog(title: title),
  );
}

Future<bool?> showMessageDialog({
  required BuildContext context,
  required String message,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (_) => custom.MessageDialog(message: message),
  );
}
