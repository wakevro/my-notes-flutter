import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/dimensions.dart';

import 'package:mynotes/router/routes.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialog/show_circular_loading.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

const tag = "ArchivedNoteView";

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map(
        (event) => event.length,
      );
}

class ArchivedNoteView extends StatefulWidget {
  const ArchivedNoteView({super.key});

  @override
  State<ArchivedNoteView> createState() => _ArchivedNoteViewState();
}

class _ArchivedNoteViewState extends State<ArchivedNoteView> {
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
    return Scaffold(
      backgroundColor: Pallete.whiteColor,
      body: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: Dimension.bodyPadding,
            decoration: const BoxDecoration(
              color: Pallete.darkMidColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.adaptive.arrow_back,
                    color: Pallete.whiteColor,
                    size: 35,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.archived,
                          style: TStyle.heading1
                              .copyWith(color: Pallete.whiteColor),
                        ),
                        StreamBuilder(
                            stream: _noteService
                                .archivedNotes(ownerUserID: userId)
                                .getLength,
                            builder: (context, AsyncSnapshot<int> snapshot) {
                              if (snapshot.hasData) {
                                final noteCount = snapshot.data ?? 0;
                                final text = context.loc.notes_title(noteCount);
                                return Text(
                                  text,
                                  style: TStyle.heading2
                                      .copyWith(color: Pallete.whiteColor),
                                );
                              }
                              return Text(context.loc.empty);
                            }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _noteService.archivedNotes(ownerUserID: userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return showCircularLoading();
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final archivedNotes =
                          snapshot.data as Iterable<CloudNote>;
                      return NotesListView(
                        notes: archivedNotes,
                        view: "archive",
                        onTemporaryDeleteNote: (note) async {
                          _noteService.temporarilyDeleteNote(
                              documentId: note.documentId,
                              value: !note.deleted);
                        },
                        onArchiveNote: (note) async {
                          _noteService.archiveNote(
                              documentId: note.documentId,
                              value: !note.archived);
                        },
                        onFinalDelete: (note) {},
                        onTap: (note) {
                          Navigator.of(context).pushNamed(createUpdateNoteRoute,
                              arguments: [note, false]);
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
          ),
        ],
      ),
    );
  }
}
