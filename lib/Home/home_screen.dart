import 'package:flutter/material.dart';
import 'add_book_dialog.dart';
import 'update_proress_dialog.dart';
import 'book_reading_screen.dart';
import '../services/book_service.dart';
import '../models/book_model.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final BookService _bookService = BookService(); // Add this
  String _selectedFilter = 'all'; // Add this for filtering

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: StreamBuilder<List<Book>>(
        // Wrap the body in StreamBuilder
        stream: _bookService.getBooksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          final filteredBooks = _selectedFilter == 'all'
              ? books
              : books.where((book) => book.status == _selectedFilter).toList();
          final wantToReadCount = books
              .where((b) => b.status == 'want_to_read')
              .length;
          final readingCount = books.where((b) => b.status == 'reading').length;
          final readCount = books.where((b) => b.status == 'read').length;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildDailyReviewCard(),
                      const SizedBox(height: 20),
                      _buildFilterChips(
                        wantToReadCount,
                        readingCount,
                        readCount,
                      ), // Pass counts
                      const SizedBox(height: 20),
                      ...filteredBooks.map(
                        (book) => _buildBookCard(book),
                      ), // Display list of books
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            width: 56,
            child: FloatingActionButton(
              heroTag: "btn1",
              mini: true,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddBookDialog(),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            width: 56,
            child: FloatingActionButton(
              heroTag: "btn2",
              mini: true,
              onPressed: () {},
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blueAccent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Trạm Đọc",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Trợ lý đọc sách chủ động & ghi nhớ",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // Open settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Tìm kiếm",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  Widget _buildDailyReviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36D1DC).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ôn tập hàng ngày",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "0 Ôn tập ngắt quãng",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orangeAccent,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  "Củng cố trí nhớ",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "5 ý tưởng cần ôn hôm nay",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ôn tập những hiểu biết quan trọng trước khi chúng phai mờ",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D68FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 45), // Full width
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bắt đầu ôn tập",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(int wantToRead, int reading, int read) {
    // Update to take counts
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            "Tất cả (${wantToRead + reading + read})",
            _selectedFilter == 'all',
            () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 10),
          _buildChip(
            "Muốn đọc ($wantToRead)",
            _selectedFilter == 'want_to_read',
            () => setState(() => _selectedFilter = 'want_to_read'),
          ),
          const SizedBox(width: 10),
          _buildChip(
            "Đang đọc ($reading)",
            _selectedFilter == 'reading',
            () => setState(() => _selectedFilter = 'reading'),
          ),
          const SizedBox(width: 10),
          _buildChip(
            "Đã đọc ($read)",
            _selectedFilter == 'read',
            () => setState(() => _selectedFilter = 'read'),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive, VoidCallback onTap) {
    // Update to take onTap
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D68FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2D68FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    double progressValue = 0;
    if (book.totalPages > 0) {
      progressValue = book.currentPage / book.totalPages;
    }
    progressValue = progressValue.clamp(0.0, 1.0);
    // Rename and update to take Book
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookReadingScreen(book: book), // Pass book if needed
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.imageUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.book,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Kệ sách phòng khách", // You can make this dynamic if needed
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value:
                                    0.47, // Placeholder; update with actual progress if tracked
                                backgroundColor: Color(0xFFEEEEEE),
                                color: Color(0xFF2D68FF),
                                minHeight: 6,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),
                          Text(
                            "${(progressValue * 100).toInt()}%", // <--- SỬA: Hiển thị % thực
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D68FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Trang ${book.currentPage}/${book.totalPages}", // <--- SỬA: Dùng dữ liệu thật
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    UpdateProgressDialog(book: book), // Pass book if needed
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: Color(0xFF2D68FF),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Cập nhật tiến độ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D68FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
