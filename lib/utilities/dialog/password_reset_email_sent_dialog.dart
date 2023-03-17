import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: "Password Reset",
      content: "You have been sent a password resent link. Check your email.",
      optionsBuilder: () => {
            "OK": null,
          });
}
