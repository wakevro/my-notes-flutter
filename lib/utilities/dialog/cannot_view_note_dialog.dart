import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showCannotViewNoteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: context.loc.recover_note,
      content: context.loc.recover_prompt,
      optionsBuilder: () => {
            context.loc.cancel: false,
            context.loc.recover: true,
          }).then(
    (value) => value ?? false,
  );
}