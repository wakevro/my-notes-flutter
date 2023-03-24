import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final bool archived;
  final bool deleted;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.archived,
    required this.deleted,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        text = snapshot.data()[textFieldName] as String,
        archived = snapshot.data()[archivedFieldName] != null
            ? snapshot.data()[archivedFieldName] as bool
            : false,
        deleted = snapshot.data()[deletedFieldName] != null
            ? snapshot.data()[deletedFieldName] as bool
            : false;

  @override
  String toString() =>
      "Cloud note text: $text, archived: $archived, deleted: $deleted documentId: $documentId, ownerUserId: $ownerUserId\n";
}
