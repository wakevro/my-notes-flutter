import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';

const String tag = "ShowPassword";

Future<bool?> showPasswordDialog(BuildContext context) async {
  TextEditingController textController = TextEditingController();
  bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
  String password = "";

  final dialogResult = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      if (isIos) {
        return CupertinoAlertDialog(
          title: Text(context.loc.password),
          content: Material(
            color: Colors.transparent,
            child: TextField(
              cursorColor: Pallete.darkColor,
              controller: textController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: context.loc.password_text_field_placeholder,
                filled: true,
                fillColor: null,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                password = value;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.loc.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(context.loc.delete),
              onPressed: () async {
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      } else {
        return AlertDialog(
          title: Text(context.loc.password),
          content: Material(
            child: TextField(
              cursorColor: Pallete.darkColor,
              obscureText: true,
              decoration: InputDecoration(
                hintText: context.loc.password_text_field_placeholder,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                password = value;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.loc.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(context.loc.delete),
              onPressed: () async {
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
    },
  );

  log("dialog: $dialogResult", name: tag);
  if (dialogResult != null && dialogResult == true) {
    final User user = FirebaseAuth.instance.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    bool result = await authenticate(user: user, credential: credential);
    log("Here: $result", name: tag);
    return result;
  }
  return dialogResult;
}

Future<bool> authenticate({
  required User user,
  required AuthCredential credential,
}) async {
  try {
    await user.reauthenticateWithCredential(credential);
    log("Successfully reauthenticated", name: tag);
    return Future.value(true);
  } catch (e) {
    log("Error reauthenticating user: $e", name: tag);

    return Future.value(false);
  }
}
