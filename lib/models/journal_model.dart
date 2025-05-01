import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:souvenir/models/journal_content_model.dart';

class JournalModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<JournalContentModel> contents;
  final String? thumbnailUrl; // Optional thumbnail for the journal
  final String? mood; // Optional mood/emotion associated with the journal
  final String? location; // Optional location where journal was created

  JournalModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.contents,
    this.thumbnailUrl,
    this.mood,
    this.location,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'contents': contents.map((content) => content.toMap()).toList(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (mood != null) 'mood': mood,
      if (location != null) 'location': location,
    };
  }

  // Create from Firestore document
  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map['id'],
      title: map['title'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      contents: (map['contents'] as List)
          .map((contentMap) => JournalContentModel.fromMap(contentMap))
          .toList(),
      thumbnailUrl: map['thumbnailUrl'],
      mood: map['mood'],
      location: map['location'],
    );
  }
}
