import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: context.loc.delete_account,
      content: context.loc.delete_account_prompt,
      optionsBuilder: () => {
            context.loc.cancel: false,
            context.loc.delete: true,
          }).then(
    (value) => value ?? false,
  );
}