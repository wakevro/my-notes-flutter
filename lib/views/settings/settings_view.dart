import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialog/delete_account.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/utilities/dialog/show_password_dialog.dart';
import 'package:mynotes/utilities/widgets/drawer_item.dart';

const String tag = "SettingsView";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.adaptive.arrow_back,
                  color: Pallete.whiteColor,
                  size: 35,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Image(
                image: AssetImage(
                  "assets/icons/settings.png",
                ),
                height: 70,
              ),
              Text(
                context.loc.settings,
                style: TStyle.heading1.copyWith(color: Pallete.whiteColor),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Divider(
              thickness: 1,
              height: 0,
            ),
            InkWell(
              child: DrawerItem(
                iconData: Icons.logout,
                iconName: context.loc.logout_button,
              ),
              onTap: () async {
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                }
              },
            ),
            InkWell(
              child: DrawerItem(
                iconData: Icons.delete,
                iconName: context.loc.delete_account,
              ),
              onTap: () async {
                final shouldDeleteAccount =
                    await showDeleteAccountDialog(context);
                if (shouldDeleteAccount) {
                  if (!mounted) return;
                  final finalResult = await showPasswordDialog(context);
                  if (!mounted) return;
                  log("final result: $finalResult", name: tag);

                  if (finalResult != null) {
                    if (finalResult) {
                      final notesStream =
                          _noteService.allUserNotes(ownerUserID: userId);
                      final allUserNotes = await notesStream.first;
                      if (!mounted) return;
                      await deleteAllNotes(allUserNotes);
                      log("Deleted all notes", name: tag);
                      if (!mounted) return;
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventDeleteAccount());
                      Navigator.of(context).pop();
                    } else {
                      await showErrorDialog(
                          context, context.loc.error_authenticating);
                    }
                  }
                }
              },
            ),
          ],
        )
      ],
    ));
  }

  Future<void> deleteAllNotes(Iterable<CloudNote> allUserNotes) async {
    for (var note in allUserNotes) {
      await _noteService.deleteNote(documentId: note.documentId);
      log("Deleted note: ${note.text}", name: tag);
    }
  }
}
