import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class JournalContentModel {
  final String type; // 'image', 'video', 'audio', or 'text'
  late final String data; // file path or text content
  final String? id; // unique identifier for each content
  final DateTime? createdAt; // when this content was added
  final int? order; // optional ordering of content

  JournalContentModel({
    required this.type,
    required this.data,
    this.id,
    this.createdAt,
    this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
      'id': id ?? const Uuid().v4(),
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : Timestamp.now(),
      if (order != null) 'order': order,
    };
  }

  factory JournalContentModel.fromMap(Map<String, dynamic> map) {
    return JournalContentModel(
      type: map['type'],
      data: map['data'],
      id: map['id'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      order: map['order'],
    );
  }
}