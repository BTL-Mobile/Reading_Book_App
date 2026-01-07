import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import 'ocr_modal.dart';

// ✅ FIX PATH (đúng theo cấu trúc bạn đang có)
import '../../../services/book_service.dart';
import '../../../models/book_model.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _noteService = NoteService();
  final _bookService = BookService();

  TextEditingController? _contentController;
  Note? _note;

  // ✅ chọn theo bookId để ổn định
  String? selectedBookId;
  String? selectedBookTitle;

  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_note != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Note) {
      _note = args;
    } else if (args is Map) {
      _note = args['note'] as Note?;
    }

    final n = _note;
    if (n == null) return;

    _contentController = TextEditingController(text: n.content);

    selectedBookId = n.bookId;
    selectedBookTitle = n.bookTitle;
  }

  @override
  void dispose() {
    _contentController?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _note;
    if (n == null || _contentController == null) return;
    if (_saving) return;

    final content = _contentController!.text.trim();
    final bookId = (selectedBookId ?? '').trim();
    final bookTitle = (selectedBookTitle ?? '').trim();

    if (content.isEmpty || bookId.isEmpty || bookTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sách và nhập nội dung.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _noteService.updateNote(
        noteId: n.id,
        content: content,
        pageNumber: n.pageNumber,
        bookId: bookId,
        bookTitle: bookTitle,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _note;
    if (n == null || _contentController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa ghi chú',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ✅ Dropdown giống ảnh 3 + realtime từ Firestore
                    StreamBuilder<List<Book>>(
                      stream: _bookService.getBooksStream(),
                      builder: (context, snapshot) {
                        final books = snapshot.data ?? const <Book>[];

                        if (snapshot.connectionState == ConnectionState.waiting && books.isEmpty) {
                          return const SizedBox(
                            height: 56,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (books.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Chưa có sách nào trong Firestore (collection: books).'),
                          );
                        }

                        // ✅ nếu note đang trỏ sách bị xoá -> default sách đầu tiên
                        final currentId = selectedBookId;
                        final exists = currentId != null && books.any((b) => b.id == currentId);

                        final value = exists ? currentId : books.first.id;

                        // cập nhật lại state cho chắc (không lỗi khi save)
                        if (!exists) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() {
                              selectedBookId = books.first.id;
                              selectedBookTitle = books.first.title;
                            });
                          });
                        }

                        return DropdownButtonFormField<String>(
                          value: value,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: books
                              .map(
                                (b) => DropdownMenuItem<String>(
                              value: b.id,
                              child: Text(
                                b.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (bookId) {
                            if (bookId == null) return;
                            final picked = books.firstWhere((x) => x.id == bookId);
                            setState(() {
                              selectedBookId = picked.id;
                              selectedBookTitle = picked.title;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const OcrModal(),
                          );
                          if (result != null && result is String) {
                            setState(() => _contentController!.text += "\n$result");
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF155DFC)),
                        label: const Text('Thêm văn bản từ ảnh (OCR)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF155DFC),
                          side: const BorderSide(color: Color(0xFF8DC5FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _contentController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Nội dung',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
