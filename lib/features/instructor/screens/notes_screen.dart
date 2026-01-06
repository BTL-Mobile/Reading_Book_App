import 'package:flutter/material.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';
import 'trash_screen.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteService _noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF155DFC),
        elevation: 0,
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạm Đọc',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Trợ lý đọc sách chủ động & ghi nhớ',
              style: TextStyle(color: Color(0xFFDAEAFE), fontSize: 13, fontWeight: FontWeight.w500),
            ),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ghi chú của tôi',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF101727)),
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<List<Note>>(
                      stream: _noteService.watchNotes(),
                      builder: (context, snapshot) {
                        final notes = snapshot.data ?? [];
                        return Text(
                          '${notes.length} ghi chú · 0 flashcards',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF697282)),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFF4B5563), size: 28),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TrashScreen()));
                      },
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddNoteScreen()),
                        );

                        if (!context.mounted) return;

                        if (created == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lưu ghi chú thành công!')),
                          );
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: Color(0xFF155DFC), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filter chips (UI)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Tất cả', isSelected: true),
                  _buildFilterChip('Flashcards'),
                  _buildFilterChip('Gần đây'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notes list
            StreamBuilder<List<Note>>(
              stream: _noteService.watchNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final msg = snapshot.error.toString();
                  if (msg.contains('failed-precondition') && msg.contains('index')) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text('Firestore đang tạo index, thử lại sau 1-2 phút nhé.',
                            style: TextStyle(color: Color(0xFF697282))),
                      ),
                    );
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Color(0xFF697282))),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Chưa có ghi chú', style: TextStyle(color: Color(0xFF697282))),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < notes.length; i++) ...[
                      _buildNoteCard(
                        context,
                        title: notes[i].status, // bạn có thể thay bằng tên sách nếu muốn map bookId
                        page: 'Trang ${notes[i].pageNumber}',
                        date: _formatDate(notes[i].updatedAt),
                        content: notes[i].content,
                        hasFlashcard: false,
                      ),
                      if (i != notes.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
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
          color: isSelected ? Colors.white : const Color(0xFF4B5563),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNoteCard(
      BuildContext context, {
        required String title,
        required String page,
        required String date,
        required String content,
        bool hasFlashcard = false,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteDetailScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF101727)),
                  ),
                ),
                if (hasFlashcard)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Flashcard',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF155DFC)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('$page • $date', style: const TextStyle(fontSize: 12, color: Color(0xFF697282))),
            const SizedBox(height: 10),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ],
        ),
      ),
    );
  }
}
