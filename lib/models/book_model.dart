import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final String category;
  final String status;
  final String content;
  final int currentPage;
  final int totalPages;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.status,
    required this.content,
    required this.currentPage,
    required this.totalPages,
  });

  /// ✅ Parse từ Firestore document
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    int _asInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    String _asString(dynamic v, [String fallback = '']) {
      if (v == null) return fallback;
      return v.toString();
    }

    return Book(
      id: doc.id,
      title: _asString(data['title']),
      author: _asString(data['author']),
      imageUrl: _asString(data['imageUrl']),
      description: _asString(data['description']),
      category: _asString(data['category']),
      status: _asString(data['status'], 'reading'),
      content: _asString(data['content']), // Firestore có thể chưa có field này
      currentPage: _asInt(data['currentPage']),
      totalPages: _asInt(data['totalPages']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'status': status,
      'content': content,
      'currentPage': currentPage,
      'totalPages': totalPages,
      // Không lưu id vào document, id là doc.id
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? imageUrl,
    String? description,
    String? category,
    String? status,
    String? content,
    int? currentPage,
    int? totalPages,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      content: content ?? this.content,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
