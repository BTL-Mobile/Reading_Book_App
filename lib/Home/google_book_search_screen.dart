import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/google_book_service.dart';

class GoogleBookSearchScreen extends StatefulWidget {
  const GoogleBookSearchScreen({super.key});

  @override
  State<GoogleBookSearchScreen> createState() => _GoogleBookSearchScreenState();
}

class _GoogleBookSearchScreenState extends State<GoogleBookSearchScreen> {
  final _searchController = TextEditingController();
  final _googleService = GoogleBookService();
  List<Book> _results = [];
  bool _isLoading = false;

  void _onSearch() async {
    setState(() => _isLoading = true);
    final books = await _googleService.searchBooks(_searchController.text);
    setState(() {
      _results = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm trên Google Books"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập tên sách (VD: Harry Potter)...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final book = _results[index];
                return ListTile(
                  leading: book.imageUrl.isNotEmpty
                      ? Image.network(
                          book.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, size: 50, color: Colors.grey),
                  title: Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(book.author, maxLines: 1),
                  onTap: () {
                    // Khi chọn sách, trả dữ liệu về màn hình trước
                    Navigator.pop(context, book);
                  },
                );
              },
            ),
    );
  }
}
