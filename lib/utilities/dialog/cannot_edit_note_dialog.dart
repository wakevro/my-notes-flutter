import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showCannotEditNoteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: context.loc.unarchive_note,
      content: context.loc.unarchive_prompt,
      optionsBuilder: () => {
            context.loc.cancel: false,
            context.loc.unarchive: true,
          }).then(
    (value) => value ?? false,
  );
}



