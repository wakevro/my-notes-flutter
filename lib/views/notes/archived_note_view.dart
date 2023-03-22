import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';

class ArchivedNoteView extends StatefulWidget {
  const ArchivedNoteView({super.key});

  @override
  State<ArchivedNoteView> createState() => _ArchivedNoteViewState();
}

class _ArchivedNoteViewState extends State<ArchivedNoteView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pallete.accentColor,
    );
  }
}
