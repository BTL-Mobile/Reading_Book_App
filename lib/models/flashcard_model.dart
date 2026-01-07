import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;
  final String bookId;
  final String frontText;
  final String backText;
  final DateTime nextReview;
  final int interval;
  final double easinessFactor;
  final int streak;

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

  // 👇 ĐÂY LÀ HÀM BẠN ĐANG THIẾU
  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Flashcard(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      frontText: data['frontText'] ?? '',
      backText: data['backText'] ?? '',
      // Xử lý an toàn: Nếu null thì lấy ngày hiện tại
      nextReview:
          (data['nextReview'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'nextReview': Timestamp.fromDate(nextReview),
      'interval': interval,
      'easinessFactor': easinessFactor,
      'streak': streak,
    };
  }
}
