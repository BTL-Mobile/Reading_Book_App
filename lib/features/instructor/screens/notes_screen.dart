import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pht_04/models/note_model.dart';
import 'package:pht_04/services/note_service.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';
import 'trash_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteService _noteService = NoteService();

  // 1. Biến trạng thái để lưu tên sách đang được chọn lọc
  String _selectedBook = 'Tất cả';

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        toolbarHeight: 115,
        backgroundColor: Colors.blueAccent,
        title: const Column(
          children: [
            Text(
              'Trạm Đọc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Trợ lý đọc sách chủ động & ghi nhớ',
              style: TextStyle(color: Color(0xFFDAEAFE), fontSize: 13),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: _noteService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // Lấy toàn bộ dữ liệu gốc từ Firebase
          final allNotes = snapshot.data ?? [];

          // 2. Tạo danh sách các tên sách duy nhất (để hiển thị lên Chips)
          // Dùng toSet() để loại bỏ các tên trùng nhau
          final Set<String> bookTitlesSet = allNotes
              .map((e) => e.bookTitle)
              .toSet();
          final List<String> bookTitles = ['Tất cả', ...bookTitlesSet];

          // 3. Lọc danh sách ghi chú theo sách đã chọn
          final displayNotes = _selectedBook == 'Tất cả'
              ? allNotes
              : allNotes
                    .where((note) => note.bookTitle == _selectedBook)
                    .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú của tôi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101727),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${displayNotes.length} ghi chú', // Hiển thị số lượng sau khi lọc
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF697282),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFF4B5563),
                            size: 28,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrashScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNoteScreen(),
                            ),
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF155DFC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- FILTER CHIPS (ĐÃ XỬ LÝ LOGIC) ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: bookTitles.map((title) {
                      final isSelected = _selectedBook == title;
                      // Đếm số lượng ghi chú của sách này (để hiện trong ngoặc)
                      final count = title == 'Tất cả'
                          ? allNotes.length
                          : allNotes.where((n) => n.bookTitle == title).length;

                      return _buildFilterChip(
                        '$title ($count)', // Hiển thị: Tên sách (Số lượng)
                        isSelected: isSelected,
                        onTap: () {
                          // Cập nhật trạng thái lọc
                          setState(() {
                            _selectedBook = title;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // --- LIST NOTES (HIỂN THỊ DANH SÁCH ĐÃ LỌC) ---
                if (displayNotes.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        _selectedBook == 'Tất cả'
                            ? "Chưa có ghi chú nào.\nHãy bấm dấu + để thêm mới!"
                            : "Không tìm thấy ghi chú nào cho sách '$_selectedBook'",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...displayNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildNoteCard(context, note: note),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget con: Đã thêm sự kiện onTap
  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      // Dùng GestureDetector để bắt sự kiện bấm
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF155DFC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, {required NoteModel note}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD22F), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          note.bookTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text("·", style: TextStyle(color: Colors.grey)),
                      ),
                      Text(
                        note.pageNumber,
                        style: const TextStyle(color: Color(0xFF374151)),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (note.hasFlashcard)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9F0A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Flashcard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(),
                InkWell(
                  onTap: () async {
                    if (note.id != null) {
                      await _noteService.moveToTrash(note.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đã chuyển vào thùng rác"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
