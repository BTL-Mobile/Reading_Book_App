import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class GoogleBookService {
  // Tìm sách trên Google Books
  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10&langRestrict=vi',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['totalItems'] == 0 || data['items'] == null) return [];

        List<dynamic> items = data['items'];

        // Chuyển đổi dữ liệu JSON từ Google thành List<Book> của chúng ta
        return items.map((item) {
          final volumeInfo = item['volumeInfo'];
          final imageLinks = volumeInfo['imageLinks'];

          return Book(
            id: '', // ID sẽ do Firebase sinh sau
            title: volumeInfo['title'] ?? 'Không có tiêu đề',
            author: (volumeInfo['authors'] as List?)?.join(', ') ?? 'Ẩn danh',
            description: volumeInfo['description'] ?? '',
            // Lấy link ảnh (ưu tiên ảnh to, nếu không có lấy ảnh nhỏ)
            imageUrl: imageLinks != null ? (imageLinks['thumbnail'] ?? '') : '',
            category: (volumeInfo['categories'] as List?)?.first ?? 'Khác',
            status: 'want_to_read', // Mặc định
            content: '', // Google không cho nội dung full
            totalPages: volumeInfo['pageCount'] ?? 0,
            currentPage: 0, // Mới thêm thì chưa đọc trang nào
          );
        }).toList();
      } else {
        throw Exception('Lỗi kết nối: ${response.statusCode}');
      }
    } catch (e) {
      print("Lỗi tìm sách: $e");
      return [];
    }
  }
}
