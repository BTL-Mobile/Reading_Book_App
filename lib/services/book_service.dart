import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cách 1: Lấy danh sách sách (Stream) - Dữ liệu tự cập nhật realtime
  Stream<List<Book>> getBooksStream() {
    return _firestore.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Cách 2: Lấy danh sách sách (Future) - Chỉ lấy 1 lần khi gọi
  Future<List<Book>> getBooksOneTime() async {
    QuerySnapshot snapshot = await _firestore.collection('books').get();
    return snapshot.docs.map((doc) {
      return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> addBook(Book book) async {
    try {
      // Chuyển đổi từ object Book sang Map (JSON) để lưu lên Firebase
      await _firestore.collection('books').add(book.toMap());
    } catch (e) {
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
      // Logic tự động chuyển trạng thái:
      // - Nếu đọc > 0 trang -> Chuyển thành "reading" (Đang đọc)
      // - Nếu đọc hết (current == total) -> Chuyển thành "read" (Đã đọc)
      String status = 'reading';
      if (currentPage >= totalPages && totalPages > 0) {
        status = 'read';
      }

      await _firestore.collection('books').doc(bookId).update({
        'currentPage': currentPage,
        'totalPages': totalPages,
        'status': status, // Cập nhật luôn trạng thái cho xịn
      });
    } catch (e) {
      print("Lỗi cập nhật tiến độ: $e");
      rethrow;
    }
  }
}
