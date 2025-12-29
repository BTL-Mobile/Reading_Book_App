import 'package:flutter/material.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';
import 'trash_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Chuyển thành final để tối ưu hiệu năng vì giá trị không thay đổi trong state này
  final int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155CFB), Color(0xFF432DD7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trạm Đọc', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Trợ lý đọc sách chủ động & ghi nhớ', style: TextStyle(color: Color(0xFFDAEAFE), fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ghi chú của tôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101727))),
                    SizedBox(height: 4),
                    Text('3 ghi chú · 2 flashcards', style: TextStyle(fontSize: 14, color: Color(0xFF697282))),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFF4B5563), size: 28),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrashScreen())),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNoteScreen())),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: Color(0xFF155DFC), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả (3)', isSelected: true),
                  _buildFilterChip('Atomic Habits'),
                  _buildFilterChip('Thinking, Fast...'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildNoteCard(
              context,
              title: 'Atomic Habits',
              page: 'Trang 15',
              date: '16/11/2024',
              content: 'Thói quen tốt là nền tảng cho sự thành công. Quy tắc 1%: Cải thiện mỗi ngày 1% sẽ tạo ra sự khác biệt lớn sau 1 năm.',
              hasFlashcard: true,
            ),
            const SizedBox(height: 16),
            _buildNoteCard(
              context,
              title: 'Atomic Habits',
              page: 'Trang 53',
              date: '18/11/2024',
              content: '4 quy luật của việc thay đổi hành vi:\n1. Làm cho nó rõ ràng\n2. Làm cho nó hấp dẫn\n3. Làm cho nó dễ dàng...',
              hasFlashcard: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF155DFC),
        unselectedItemColor: const Color(0xFF9CA3AF),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'Ôn tập'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Vòng tròn'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF155DFC) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, {required String title, required String page, required String date, required String content, bool hasFlashcard = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteDetailScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD22F), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("·", style: TextStyle(color: Colors.grey))),
                    Text(page, style: const TextStyle(color: Color(0xFF374151))),
                  ],
                ),
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasFlashcard)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9F0A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Flashcard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                const Icon(Icons.delete_outline, color: Color(0xFF9CA3AF), size: 20),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.push_pin, size: 12, color: Color(0xFFB45309)),
                SizedBox(width: 4),
                Text('Ghi chú này sẽ được đưa vào lịch ôn tập', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
              ],
            )
          ],
        ),
      ),
    );
  }
}