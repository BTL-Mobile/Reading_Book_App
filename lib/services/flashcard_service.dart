import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard_model.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Root collection đúng với Firestore hiện tại của bạn
  CollectionReference<Map<String, dynamic>> _col() {
    return _firestore.collection('flashcards');
  }

  // =========================
  // 1) LẤY DỮ LIỆU (Stream) - TẤT CẢ
  // =========================
  Stream<List<Flashcard>> getFlashcardsStream() {
    // Sắp xếp theo createdAt mới nhất (nếu có)
    return _col()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();
    });
  }

  // =========================
  // 1b) LẤY DỮ LIỆU (Stream) - THEO BOOKID (✅ bạn cần cái này)
  // =========================
  Stream<List<Flashcard>> getFlashcardsByBookIdStream(String bookId) {
    return _col()
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();
    });
  }

  // =========================
  // 2) THÊM THẺ MỚI (tạo vào /flashcards)
  // =========================
  Future<void> addCard(String bookId, String front, String back,
      {String? bookTitle, String? noteId}) async {
    await _col().add({
      'bookId': bookId,
      if (bookTitle != null) 'bookTitle': bookTitle,
      if (noteId != null) 'noteId': noteId,

      // ✅ tương thích model/service cũ
      'frontText': front,
      'backText': back,

      // ✅ tương thích note -> flashcard đang dùng question/answer
      'question': front,
      'answer': back,

      // ✅ ôn ngay
      'nextReview': Timestamp.now(),
      'dueAt': Timestamp.now(), // nếu màn ôn tập dùng dueAt

      'interval': 0,
      'streak': 0,
      'easinessFactor': 2.5,

      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 3) CẬP NHẬT TRẠNG THÁI ÔN TẬP (SM-2)
  // =========================
  Future<void> updateReviewStatus(
      String cardId,
      DateTime nextReview,
      int interval,
      double easinessFactor,
      int streak,
      ) async {
    await _col().doc(cardId).update({
      'nextReview': Timestamp.fromDate(nextReview),
      'dueAt': Timestamp.fromDate(nextReview),
      'interval': interval,
      'easinessFactor': easinessFactor,
      'streak': streak,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // 4) XÓA THẺ
  // =========================
  Future<void> deleteCard(String cardId) async {
    await _col().doc(cardId).delete();
  }

  // =========================
  // 5) SỬA NỘI DUNG THẺ
  // =========================
  Future<void> updateCardContent(
      String cardId,
      String newFront,
      String newBack,
      ) async {
    await _col().doc(cardId).update({
      'frontText': newFront,
      'backText': newBack,
      'question': newFront,
      'answer': newBack,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
