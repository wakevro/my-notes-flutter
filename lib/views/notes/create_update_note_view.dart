import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialog/cannot_edit_note_dialog.dart';
import 'package:mynotes/utilities/dialog/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

String tag = "CreateUpdateNoteView";

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textController;

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerlistener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<List>();

    if (widgetNote != null) {
      log("There is an existing note", name: tag);
      _note = widgetNote[0];
      _textController.text = widgetNote[0].text;
      return widgetNote[0];
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    log("There is no existing note", name: tag);
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _noteService.createNewNote(ownerUserid: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      log("Note is empty", name: tag);
      _noteService.deleteNote(documentId: note.documentId);
    } else {
      log("Note is not empty: Note: ${note?.text}", name: tag);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.whiteColor,
      body: Column(
        children: [
          Container(
            padding: Dimension.bodyPadding,
            margin: const EdgeInsets.only(bottom: 0),
            alignment: Alignment.bottomCenter,
            height: 150,
            decoration: const BoxDecoration(
              color: Pallete.darkMidColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.adaptive.arrow_back,
                    size: 29,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  context.loc.note,
                  style: TStyle.heading2
                      .copyWith(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.adaptive.share,
                    size: 29,
                  ),
                  onTap: () async {
                    final text = _textController.text;
                    if (_note == null || text.isEmpty) {
                      await showCannotShareEmptyNoteDialog(context);
                    } else {
                      Share.share(text);
                    }
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: FutureBuilder(
                future: createOrGetExistingNote(context),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      log("New note info: $_note", name: tag);
                      _setupTextControllerlistener();
                      final gottenArgument = context.getArgument<List>();
                      return GestureDetector(
                        onTap: () async {
                          if (!gottenArgument?[1]) {
                            final shouldUnarchive =
                                await showCannotEditNoteDialog(context);
                            if (shouldUnarchive) {
                              _noteService.archiveNote(
                                  documentId: _note!.documentId, value: false);
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: TextField(
                          enabled: gottenArgument?[1],
                          decoration: InputDecoration(
                            hintText: context.loc.start_typing_your_note,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Pallete.lightColor.withOpacity(0.1),
                          ),
                          controller: _textController,
                          cursorColor: Pallete.darkColor,
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: TStyle.bodyMedium,
                        ),
                      );
                    default:
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
