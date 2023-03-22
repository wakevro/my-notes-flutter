import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: context.loc.delete,
      content: context.loc.delete_note_prompt,
      optionsBuilder: () => {
            context.loc.cancel: false,
            context.loc.delete: true,
          }).then(
    (value) => value ?? false,
  );
}

Future<bool> showFinalDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: context.loc.delete,
      content: context.loc.final_delete_note_prompt,
      optionsBuilder: () => {
            context.loc.cancel: false,
            context.loc.delete: true,
          }).then(
    (value) => value ?? false,
  );
}
