import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/drawer_head.dart';
import 'package:mynotes/drawer_item.dart';
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
    bool isIos = Theme.of(context).platform == TargetPlatform.iOS;
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
            children: [
              const DrawerHead(),
              Column(
                children: [
                  const Divider(
                    thickness: 1,
                    height: 0,
                  ),
                  DrawerItem(
                    iconData: Icons.archive_rounded,
                    iconName: context.loc.archived,
                    route: archivedViewRoute,
                  ),
                  DrawerItem(
                    iconData: Icons.delete,
                    iconName: context.loc.recently_deleted,
                    route: deletedViewRoute,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            padding: Dimension.bodyPadding,
            height: 200,
            decoration: const BoxDecoration(
              color: Pallete.darkMidColor,
            ),
            child: Column(
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
                    Row(
                      children: [
                        Container(
                          width: isIos ? 40 : 30,
                          height: isIos ? 30 : 40,
                          decoration: BoxDecoration(
                              color: Pallete.darkColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10)),
                          child: FractionallySizedBox(
                            widthFactor: 1.5,
                            heightFactor: 1.5,
                            child: PlatformPopupMenu(
                              options: [
                                PopupMenuOption(
                                  label: context.loc.logout_button,
                                  onTap: (p0) async {
                                    final shouldLogout =
                                        await showLogoutDialog(context);
                                    if (shouldLogout) {
                                      if (!mounted) return;
                                      context.read<AuthBloc>().add(
                                            const AuthEventLogOut(),
                                          );
                                    }
                                  },
                                ),
                              ],
                              icon: PlatformWidget(
                                cupertino: (context, platform) {
                                  return const Icon(
                                    CupertinoIcons.ellipsis,
                                    size: 30,
                                  );
                                },
                                material: (context, platform) {
                                  return const Icon(
                                    Icons.more_vert,
                                    size: 30,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
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
