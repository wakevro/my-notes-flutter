import 'dart:developer';
import 'package:mynotes/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/utilities/show_circular_loading.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

const tag = "NotesView";

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteService = NoteService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String savedUserEmail = userEmail;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Notes"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton(
              onSelected: (value) async {
                log("Value: $value selected", name: tag);
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogoutDialog(context);
                    log("User clicked '$shouldLogout' for log out dialog",
                        name: tag);
                    if (shouldLogout) {
                      log("Starting to sign out.....", name: tag);
                      await AuthService.firebase().logOut();
                      log("User signed out of email: $savedUserEmail",
                          name: tag);

                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text("Log out"),
                  ),
                ];
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _noteService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return showCircularLoading();
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            log("All notes: $allNotes", name: tag);
                            return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                _noteService.deleteNote(id: note.id);
                              },
                              onTap: (note) {
                                Navigator.of(context).pushNamed(
                                    createUpdateNoteRoute,
                                    arguments: note);
                              },
                            );
                          } else {
                            return showCircularLoading();
                          }
                        default:
                          return showCircularLoading();
                      }
                    });

              default:
                return showCircularLoading();
            }
          },
        ));
  }
}
