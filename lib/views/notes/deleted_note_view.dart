import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';

class DeletedNoteView extends StatefulWidget {
  const DeletedNoteView({super.key});

  @override
  State<DeletedNoteView> createState() => _DeletedNoteViewState();
}

class _DeletedNoteViewState extends State<DeletedNoteView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pallete.accentColor,
    );
  }
}
