import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String content;
  final int pageNumber;
  final String status;

  final String bookId;
  final String bookTitle;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  final bool isConverted;

  Note({
    required this.id,
    required this.content,
    required this.pageNumber,
    required this.status,
    required this.bookId,
    required this.bookTitle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isConverted,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final bookId = (data['bookId'] ?? '').toString();
    final bookTitleRaw = (data['bookTitle'] ?? data['bookName'] ?? bookId).toString();

    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;
    final deletedTs = data['deletedAt'] as Timestamp?;

    return Note(
      id: doc.id,
      content: (data['content'] ?? '').toString(),
      pageNumber: (data['pageNumber'] ?? 0) is int
          ? (data['pageNumber'] ?? 0) as int
          : int.tryParse((data['pageNumber'] ?? '0').toString()) ?? 0,
      status: (data['status'] ?? 'active').toString(),
      bookId: bookId,
      bookTitle: bookTitleRaw.isEmpty ? 'Sách' : bookTitleRaw,
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate() ?? DateTime.now(),
      deletedAt: deletedTs?.toDate(),
      isConverted: (data['isConverted'] ?? false) as bool,
    );
  }
}
