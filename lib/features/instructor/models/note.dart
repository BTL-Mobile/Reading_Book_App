import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String content;
  final int pageNumber;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.content,
    required this.pageNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Note(
      id: doc.id,
      content: data['content'],
      pageNumber: data['pageNumber'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
