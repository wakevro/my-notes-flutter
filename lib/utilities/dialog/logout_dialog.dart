import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: "Log out",
      content: "Are you sure you want to log out?",
      optionsBuilder: () => {
            "Cancel": false,
            "Log out": true,
          }).then(
    (value) => value ?? false,
  );
}
