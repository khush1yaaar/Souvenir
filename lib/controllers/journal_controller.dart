import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:souvenir/models/journal_content_model.dart';
import 'package:souvenir/models/journal_model.dart';

class JournalController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addJournal(String userId, JournalModel journal) async {
    try {
      // Reference to the user's journals collection
      final journalRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .doc(journal.id);

      // First upload all media files to Storage if needed
      await _uploadMediaFiles(journal.contents);

      // Then save the journal document
      await journalRef.set(journal.toMap());

      // Update the user's journals map with a reference to this journal
      await _firestore.collection('users').doc(userId).update({
        'journals.${journal.id}': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding journal: $e');
      rethrow;
    }
  }

  Future<void> _uploadMediaFiles(List<JournalContentModel> contents) async {
    for (JournalContentModel content in contents) {
      if (content.type != 'text') {
        // For media files, we need to upload to Firebase Storage
        final file = File(content.data);
        final ref = _storage.ref().child('media/${content.id}');
        await ref.putFile(file);
        // Update the content data with the download URL
        content.data = await ref.getDownloadURL();
      }
    }
  }

  Future<List<JournalModel>> getUserJournals(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('journals')
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => JournalModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting journals: $e');
      rethrow;
    }
  }

  Future<void> updateJournal(String userId, JournalModel journal) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .doc(journal.id)
          .update(journal.toMap());
    } catch (e) {
      print('Error updating journal: $e');
      rethrow;
    }
  }

  Future<void> deleteJournal(String userId, String journalId) async {
    try {
      // First get the journal to delete associated media files
      final journalDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('journals')
              .doc(journalId)
              .get();

      if (journalDoc.exists) {
        final journal = JournalModel.fromMap(journalDoc.data()!);
        await _deleteMediaFiles(journal.contents);

        // Then delete the journal document
        await journalDoc.reference.delete();

        // Remove from user's journals map
        await _firestore.collection('users').doc(userId).update({
          'journals.$journalId': FieldValue.delete(),
        });
      }
    } catch (e) {
      print('Error deleting journal: $e');
      rethrow;
    }
  }

  Future<void> _deleteMediaFiles(List<JournalContentModel> contents) async {
    for (var content in contents) {
      if (content.type != 'text') {
        try {
          await _storage.refFromURL(content.data).delete();
        } catch (e) {
          print('Error deleting media file: $e');
        }
      }
    }
  }
}
