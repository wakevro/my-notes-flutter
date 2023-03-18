import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/utilities/dialog/show_circular_loading.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

const tag = "NotesView";

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map(
        (event) => event.length,
      );
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String savedUserEmail = userEmail;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
            stream: _noteService.allNotes(ownerUserID: userId).getLength,
            builder: (context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                final text = context.loc.notes_title(noteCount);
                return Text(text);
              }
              return const Text("");
            }),
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
                    if (!mounted) return;
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                    log("User signed out of email: $savedUserEmail", name: tag);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _noteService.allNotes(ownerUserID: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return showCircularLoading();
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                final Iterable printableNotes =
                    allNotes.map((note) => note.toString());
                log("Notes: ${printableNotes.toString()}", name: tag);
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    _noteService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context)
                        .pushNamed(createUpdateNoteRoute, arguments: note);
                  },
                );
              } else {
                return showCircularLoading();
              }
            default:
              return showCircularLoading();
          }
        },
      ),
    );
  }
}
