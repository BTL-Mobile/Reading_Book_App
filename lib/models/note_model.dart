import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String? id;
  String bookTitle; // Tên sách (VD: Atomic Habits)
  String content; // Nội dung ghi chú
  String pageNumber; // Số trang (VD: Trang 15)
  bool hasFlashcard; // Có flashcard không
  DateTime createdAt; // Ngày tạo
  bool isDeleted; // Trạng thái đã xóa (để đưa vào thùng rác)

  NoteModel({
    this.id,
    required this.bookTitle,
    required this.content,
    required this.pageNumber,
    this.hasFlashcard = false,
    required this.createdAt,
    this.isDeleted = false,
  });

  // Chuyển từ Firestore Document sang Object Dart
  factory NoteModel.fromMap(Map<String, dynamic> data, String id) {
    return NoteModel(
      id: id,
      bookTitle: data['bookTitle'] ?? '',
      content: data['content'] ?? '',
      pageNumber: data['pageNumber'] ?? '',
      hasFlashcard: data['hasFlashcard'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Chuyển từ Object Dart sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookTitle': bookTitle,
      'content': content,
      'pageNumber': pageNumber,
      'hasFlashcard': hasFlashcard,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
    };
  }
}
