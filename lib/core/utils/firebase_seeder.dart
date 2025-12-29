import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Để sử dụng debugPrint

class FirebaseSeeder {
  static Future<void> seedNotes() async {
    final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    // Dữ liệu mẫu khớp với các trường trong notes_screen.dart của bạn
    List<Map<String, dynamic>> dummyData = [
      {
        'book_title': 'Atomic Habits',
        'page': '15',
        'content': 'Thói quen tốt là nền tảng cho sự thành công. Quy tắc 1%: Cải thiện mỗi ngày 1% sẽ tạo ra sự khác biệt lớn sau 1 năm.',
        'is_flashcard': true,
        'created_at': FieldValue.serverTimestamp(),
        'is_deleted': false,
      },
      {
        'book_title': 'Deep Work',
        'page': '42',
        'content': 'Làm việc sâu giúp tối ưu hóa khả năng nhận thức và tạo ra kết quả vượt trội.',
        'is_flashcard': false,
        'created_at': FieldValue.serverTimestamp(),
        'is_deleted': false,
      }
    ];

    for (var data in dummyData) {
      await notes.add(data);
    }
    // Sửa print thành debugPrint để xóa lỗi info
    debugPrint(">>> ĐÃ SEED DỮ LIỆU MẪU LÊN FIRESTORE!");
  }
}