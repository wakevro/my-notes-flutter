import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const tag = "NotesView";

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main "),
        actions: [
          PopupMenuButton(onSelected: (value) async {
            log("Value: $value selected", name: tag);
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                log("User clicked '$shouldLogout' for log out dialog",
                    name: tag);
                if (shouldLogout) {
                  log("Starting to sign out.....", name: tag);
                  await FirebaseAuth.instance.signOut();
                  log("User signed out", name: tag);

                  // ignore:, use_build_context_synchronously
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/login/", (route) => false);
                }

                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text("Log out"),
              )
            ];
          })
        ],
      ),
      body: const Text("Hello world"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Log out")),
        ],
      );
    },
  ).then((value) => value ?? false);
}
