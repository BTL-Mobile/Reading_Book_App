import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;
  final String bookId; // Liên kết với sách nào
  final String frontText; // Mặt trước (Câu hỏi)
  final String backText; // Mặt sau (Đáp án)
  final DateTime nextReview; // Ngày ôn tập tiếp theo
  final int interval; // Khoảng cách ngày (dùng cho thuật toán lặp lại)
  final double easinessFactor; // Độ dễ (dùng cho thuật toán)
  final int streak; // Chuỗi ngày nhớ liên tục

  Flashcard({
    required this.id,
    required this.bookId,
    required this.frontText,
    required this.backText,
    required this.nextReview,
    this.interval = 0,
    this.easinessFactor = 2.5,
    this.streak = 0,
  });

  factory Flashcard.fromMap(Map<String, dynamic> data, String documentId) {
    return Flashcard(
      id: documentId,
      bookId: data['bookId'] ?? '',
      frontText: data['frontText'] ?? '',
      backText: data['backText'] ?? '',
      nextReview: (data['nextReview'] as Timestamp).toDate(),
      interval: data['interval'] ?? 0,
      easinessFactor: (data['easinessFactor'] ?? 2.5).toDouble(),
      streak: data['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'frontText': frontText,
      'backText': backText,
      'nextReview': nextReview,
      'interval': interval,
      'easinessFactor': easinessFactor,
      'streak': streak,
    };
  }
}
