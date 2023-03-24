import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  factory FirebaseCloudStorage() => _shared;
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();

  final notes = FirebaseFirestore.instance.collection("notes");

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserID}) {
    final allNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserID,
        )
        .where(
          archivedFieldName,
          isEqualTo: false,
        )
        .where(
          deletedFieldName,
          isEqualTo: false,
        )
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }

  Stream<Iterable<CloudNote>> allUserNotes({required String ownerUserID}) {
    final allNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserID,
        )
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }

  Stream<Iterable<CloudNote>> archivedNotes({required String ownerUserID}) {
    final archivedNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserID,
        )
        .where(
          archivedFieldName,
          isEqualTo: true,
        )
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return archivedNotes;
  }

  Stream<Iterable<CloudNote>> deletedNotes({required String ownerUserID}) {
    final deletedNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserID,
        )
        .where(
          deletedFieldName,
          isEqualTo: true,
        )
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return deletedNotes;
  }

  Future<CloudNote> createNewNote({
    required String ownerUserid,
  }) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserid,
      textFieldName: "",
      archivedFieldName: false,
      deletedFieldName: false,
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserid,
      text: "",
      archived: false,
      deleted: false,
    );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update(
        {textFieldName: text},
      );
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> archiveNote({
    required String documentId,
    required bool value,
  }) async {
    try {
      await notes.doc(documentId).update(
        {
          archivedFieldName: value,
          deletedFieldName: false,
        },
      );
    } catch (e) {
      throw CouldNotArchiveNoteException();
    }
  }

  Future<void> temporarilyDeleteNote({
    required String documentId,
    required bool value,
  }) async {
    try {
      await notes.doc(documentId).update(
        {
          deletedFieldName: value,
          archivedFieldName: false,
        },
      );
    } catch (e) {
      throw CouldNotTemporarilyDeleteNoteException();
    }
  }
}
