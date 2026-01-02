import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/flashcard_model.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Lấy đúng đường dẫn vào Sub-collection của user
  CollectionReference? _getCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('flashcards');
  }

  // 1. LẤY DỮ LIỆU (Stream)
  Stream<List<Flashcard>> getFlashcardsStream() {
    final col = _getCollection();
    if (col == null) return const Stream.empty();

    // Sắp xếp theo ngày tạo mới nhất lên đầu
    return col.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();
    });
  }

  // 2. THÊM THẺ MỚI
  Future<void> addCard(String bookId, String front, String back) async {
    final col = _getCollection();
    if (col != null) {
      await col.add({
        'bookId': bookId,
        'frontText': front,
        'backText': back,
        'nextReview': Timestamp.now(), // Ôn ngay
        'interval': 0,
        'streak': 0,
        'easinessFactor': 2.5,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 3. CẬP NHẬT TRẠNG THÁI ÔN TẬP (Dùng cho thuật toán SM-2)
  Future<void> updateReviewStatus(
    String cardId,
    DateTime nextReview,
    int interval,
    double easinessFactor,
    int streak,
  ) async {
    final col = _getCollection();
    if (col != null) {
      await col.doc(cardId).update({
        'nextReview': Timestamp.fromDate(nextReview),
        'interval': interval,
        'easinessFactor': easinessFactor,
        'streak': streak,
      });
    }
  }

  // --- 👇 CÁC HÀM MỚI BỔ SUNG 👇 ---

  // 4. XÓA THẺ (Delete)
  Future<void> deleteCard(String cardId) async {
    final col = _getCollection();
    if (col != null) {
      await col.doc(cardId).delete();
    }
  }

  // 5. SỬA NỘI DUNG THẺ (Update Content)
  Future<void> updateCardContent(
    String cardId,
    String newFront,
    String newBack,
  ) async {
    final col = _getCollection();
    if (col != null) {
      await col.doc(cardId).update({
        'frontText': newFront,
        'backText': newBack,
        // Có thể thêm 'updatedAt': FieldValue.serverTimestamp() nếu cần
      });
    }
  }
}
