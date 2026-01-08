import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ CÁCH 1: Books dùng chung -> KHÔNG lọc userId, KHÔNG yêu cầu đăng nhập
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection('books')
    // Nếu bạn gặp lỗi index/orderBy thì xóa dòng orderBy này
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // ✅ dùng đúng factory trong model
        return Book.fromFirestore(doc);
      }).toList();
    });
  }

  /// ✅ One-time: lấy 1 lần
  Future<List<Book>> getBooksOneTime() async {
    final snapshot =
    await _firestore.collection('books').orderBy('title').get();

    return snapshot.docs.map((doc) {
      return Book.fromFirestore(doc);
    }).toList();
  }

  /// ✅ Thêm sách (books chung)
  /// - không bắt buộc userId
  /// - nếu đang đăng nhập thì vẫn gắn userId (optional, để về sau dùng)
  Future<void> addBook(Book book) async {
    try {
      final data = book.toMap();

      final uid = _auth.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        data['userId'] = uid;
      }

      data['createdAt'] = data['createdAt'] ?? FieldValue.serverTimestamp();
      data['updatedAt'] = data['updatedAt'] ?? FieldValue.serverTimestamp();

      await _firestore.collection('books').add(data);
    } catch (e) {
      // ignore: avoid_print
      print("Lỗi thêm sách: $e");
      rethrow;
    }
  }

  Future<void> updateReadingProgress(
      String bookId,
      int currentPage,
      int totalPages,
      ) async {
    try {
      String status = 'reading';
      if (currentPage >= totalPages && totalPages > 0) {
        status = 'read';
      }

      await _firestore.collection('books').doc(bookId).update({
        'currentPage': currentPage,
        'totalPages': totalPages,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      print("Lỗi cập nhật tiến độ: $e");
      rethrow;
    }
  }
}
