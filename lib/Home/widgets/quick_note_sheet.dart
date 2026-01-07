import 'package:flutter/material.dart';

// 🔧 IMPORT ĐÚNG NoteService trong project của bạn
import '../../features/instructor/services/note_service.dart';

class QuickNoteSheet extends StatefulWidget {
  final int currentPage;
  final String bookId;
  final String bookTitle;

  const QuickNoteSheet({
    super.key,
    required this.currentPage,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<QuickNoteSheet> createState() => _QuickNoteSheetState();
}

class _QuickNoteSheetState extends State<QuickNoteSheet> {
  final TextEditingController _controller = TextEditingController();
  final NoteService _noteService = NoteService();

  bool _saving = false;

  Future<void> _saveNote() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _saving = true);

    try {
      // ✅ DÙNG addNote (ĐÚNG VỚI NoteService CỦA BẠN)
      await _noteService.addNote(
        content: content,
        bookId: widget.bookId,
        bookTitle: widget.bookTitle,
        pageNumber: widget.currentPage,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu ghi chú thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú nhanh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Trang ${widget.currentPage} • ${widget.bookTitle}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập suy nghĩ, ý tưởng của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveNote,
                    child: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Lưu ghi chú'),
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
