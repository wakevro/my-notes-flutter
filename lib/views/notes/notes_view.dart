import 'dart:developer';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/utilities/widgets/drawer_head.dart';
import 'package:mynotes/utilities/widgets/drawer_item.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createUpdateNoteRoute);
        },
        backgroundColor: Pallete.darkColor,
        child: const Icon(Icons.edit_outlined),
      ),
      backgroundColor: Pallete.whiteColor,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              DrawerHead(
                title: context.loc.folders,
                filePath: "assets/images/note.png",
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 230,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Divider(
                          thickness: 1,
                          height: 0,
                        ),
                        InkWell(
                          child: DrawerItem(
                            iconData: Icons.archive_rounded,
                            iconName: context.loc.archived,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(archivedViewRoute),
                        ),
                        InkWell(
                          child: DrawerItem(
                            iconData: Icons.delete,
                            iconName: context.loc.recently_deleted,
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed(deletedViewRoute),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Divider(
                          thickness: 1,
                          height: 0,
                        ),
                        InkWell(
                          child: DrawerItem(
                            iconData: Icons.settings,
                            iconName: context.loc.settings,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(settingsViewRoute),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: Dimension.bodyPadding,
            decoration: const BoxDecoration(
              color: Pallete.darkMidColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    if (_scaffoldKey.currentState != null) {
                      _scaffoldKey.currentState!.openDrawer();
                    }
                  },
                  child: const Icon(
                    Icons.menu,
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
                          context.loc.notes,
                          style: TStyle.heading1
                              .copyWith(color: Pallete.whiteColor),
                        ),
                        StreamBuilder(
                            stream: _noteService
                                .allNotes(ownerUserID: userId)
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
                        view: "notes",
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
                              arguments: [note, true]);
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
