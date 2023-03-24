import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';

typedef DialogOptionsBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionsBuilder optionsBuilder,
}) {
  final options = optionsBuilder();

  bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
  if (isIos) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: options.keys.map((optionTitle) {
            final T value = options[optionTitle];
            return TextButton(
                onPressed: () {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  optionTitle,
                  style: title == context.loc.delete_account &&
                          optionTitle == context.loc.delete
                      ? const TextStyle(color: Pallete.redColor)
                      : const TextStyle(color: Pallete.darkColor),
                ));
          }).toList(),
        );
      },
    );
  } else {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: options.keys.map((optionTitle) {
            final T value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                optionTitle,
                style: title == context.loc.delete_account &&
                        optionTitle == context.loc.delete
                    ? const TextStyle(color: Pallete.redColor)
                    : const TextStyle(color: Pallete.darkColor),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
