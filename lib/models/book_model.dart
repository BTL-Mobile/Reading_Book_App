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
    this.content = '',
    this.currentPage = 0,
    this.totalPages = 0,
  });

  factory Book.fromMap(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? 'Không có tiêu đề',
      author: data['author'] ?? 'Ẩn danh',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Khác',
      status: data['status'] ?? 'want_to_read',
      content: data['content'] ?? '',
      currentPage: data['currentPage'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
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
    };
  }
}
