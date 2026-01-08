import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;

  // ===== DỮ LIỆU THẬT TỪ FIRESTORE =====
  final String bookId;
  final String bookTitle;
  final String question;
  final String answer;

  final DateTime nextReview;
  final int interval;
  final double easinessFactor;
  final int streak;

  Flashcard({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.question,
    required this.answer,
    required this.nextReview,
    this.interval = 0,
    this.easinessFactor = 2.5,
    this.streak = 0,
  });

  // ==========================
  // 🔥 MAP ĐÚNG FIRESTORE
  // ==========================
  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Flashcard(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      nextReview:
      (data['nextReview'] as Timestamp?)?.toDate() ?? DateTime.now(),
      interval: data['interval'] ?? 0,
      easinessFactor: (data['easinessFactor'] ?? 2.5).toDouble(),
      streak: data['streak'] ?? 0,
    );
  }

  // ==========================
  // 🧩 GETTER TƯƠNG THÍCH UI CŨ
  // ==========================

  /// UI đang dùng frontText
  String get frontText => question;

  /// UI đang dùng backText
  String get backText => answer;

  /// UI đang dùng reviewCount
  int get reviewCount => streak;

  /// UI đang dùng dueText
  String get dueText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
    DateTime(nextReview.year, nextReview.month, nextReview.day);

    final diff = target.difference(today).inDays;

    if (diff <= 0) return 'Hôm nay';
    if (diff == 1) return 'Sau 1 ngày';
    return 'Sau $diff ngày';
  }

  // ==========================
  // GHI NGƯỢC (nếu cần)
  // ==========================
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'question': question,
      'answer': answer,
      'nextReview': Timestamp.fromDate(nextReview),
      'interval': interval,
      'easinessFactor': easinessFactor,
      'streak': streak,
    };
  }
}
