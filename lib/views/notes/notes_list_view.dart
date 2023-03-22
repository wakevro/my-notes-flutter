import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialog/delete_dialog.dart';
import 'package:share_plus/share_plus.dart';

const String tag = "NoteListView";

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onTemporaryDeleteNote;
  final NoteCallback onArchiveNote;
  final NoteCallback onFinalDelete;
  final NoteCallback onTap;
  final String view;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onTemporaryDeleteNote,
    required this.onTap,
    required this.onArchiveNote,
    required this.view,
    required this.onFinalDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListItem(
          noteText: note.text,
          onTap: onTap,
          note: note,
          onTemporaryDeleteNote: onTemporaryDeleteNote,
          onArchiveNote: onArchiveNote,
          view: view,
          onFinalDelete: onFinalDelete,
        );
      },
    );
  }
}

class ListItem extends StatelessWidget {
  final String noteText;
  final String view;
  final NoteCallback onTap;
  final NoteCallback onTemporaryDeleteNote;
  final NoteCallback onArchiveNote;
  final NoteCallback onFinalDelete;
  final CloudNote note;

  const ListItem({
    super.key,
    required this.noteText,
    required this.onTap,
    required this.note,
    required this.onTemporaryDeleteNote,
    required this.onArchiveNote,
    required this.view,
    required this.onFinalDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // Share
            if (view != "delete")
              SlidableAction(
                backgroundColor: Pallete.accentColor,
                icon: Icons.adaptive.share,
                onPressed: (context) {
                  Share.share(noteText);
                },
              ),
            // Archive
            if (view == "notes")
              SlidableAction(
                backgroundColor: Pallete.purpleColor,
                icon: Icons.archive,
                onPressed: (context) {
                  onArchiveNote(note);
                },
              ),
            // Recover
            if (view == "delete")
              SlidableAction(
                backgroundColor: Pallete.greenColor,
                icon: Icons.restore,
                onPressed: (context) async {
                  onTemporaryDeleteNote(note);
                },
              ),
            // Unarchive
            if (view == "archive")
              SlidableAction(
                backgroundColor: Pallete.greenColor,
                icon: Icons.unarchive,
                onPressed: (context) {
                  onArchiveNote(note);
                },
              ),
            // Temporary Delete
            if (view != "delete")
              SlidableAction(
                backgroundColor: Pallete.redColor,
                icon: Icons.delete,
                onPressed: (context) async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onTemporaryDeleteNote(note);
                  }
                },
              ),
            // Final Delete
            if (view == "delete")
              SlidableAction(
                backgroundColor: Pallete.redColor,
                icon: Icons.delete,
                onPressed: (context) async {
                  final shouldDelete = await showFinalDeleteDialog(context);
                  if (shouldDelete) {
                    log("Trying to final delete", name: tag);
                    onFinalDelete(note);
                  }
                },
              ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 0, bottom: 8),
          padding: Dimension.itemPadding,
          decoration: BoxDecoration(
              color: Pallete.lightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.folder_fill),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        noteText,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TStyle.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        onTap(note);
      },
    );
  }
}
