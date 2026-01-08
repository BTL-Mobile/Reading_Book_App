import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/note_service.dart';
import '../screens/ocr_modal.dart';

// ⚠️ chỉnh đường dẫn nếu khác
import '../../../services/book_service.dart';
import '../../../models/book_model.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  /// ✅ show đúng kiểu ảnh (bottom sheet)
  static Future<bool?> open(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddNoteScreen(),
    );
  }

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _noteService = NoteService();
  final _bookService = BookService();

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  String? selectedBookId;
  String? selectedBookTitle;

  bool isFlashcard = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      if (mounted) setState(() {}); // cập nhật counter 0/5000
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
    );
  }

  Widget _label(String text, {bool required = false, Widget? right}) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              children: [
                TextSpan(text: text),
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        if (right != null) right,
      ],
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập trước khi lưu ghi chú.')),
      );
      return;
    }

    final content = _contentController.text.trim();
    final pageNumber = int.tryParse(_pageController.text.trim()) ?? 0;

    final bookId = selectedBookId;
    final bookTitle = selectedBookTitle;

    if (bookId == null || bookId.isEmpty || bookTitle == null || bookTitle.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sách trước khi lưu.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _noteService.addNote(
        content: content,
        pageNumber: pageNumber,
        bookId: bookId,
        bookTitle: bookTitle,
        userId: uid,
        createFlashcardFlag: isFlashcard, // ✅ quan trọng
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _bookDropdown() {
    return StreamBuilder<List<Book>>(
      stream: _bookService.getBooksStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snap.hasError) {
          return Text(
            'Lỗi tải sách: ${snap.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final books = snap.data ?? [];
        if (books.isEmpty) {
          return TextFormField(
            enabled: false,
            decoration: _inputDecoration(
              hintText: 'Chưa có sách trong Firestore. Hãy tạo sách trước.',
            ),
          );
        }

        if (selectedBookId != null && !books.any((b) => b.id == selectedBookId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              selectedBookId = null;
              selectedBookTitle = null;
            });
          });
        }

        return DropdownButtonFormField<String>(
          decoration: _inputDecoration(hintText: 'Chọn sách'),
          value: selectedBookId,
          items: books.map((b) {
            final t = b.title.trim();
            return DropdownMenuItem<String>(
              value: b.id,
              child: Text(t.isEmpty ? '(Không có tên sách)' : t),
            );
          }).toList(),
          onChanged: (id) {
            if (id == null) return;
            final book = books.firstWhere((b) => b.id == id);
            setState(() {
              selectedBookId = book.id;
              selectedBookTitle = book.title.trim();
            });
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng chọn sách' : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Material(
        color: Colors.transparent, // ✅ cần Material ancestor
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              color: const Color(0xFFF9FAFB),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ghi chú mới',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 26),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Chọn sách', required: true),
                            const SizedBox(height: 8),
                            _bookDropdown(),

                            const SizedBox(height: 16),
                            _label('Số trang (tùy chọn)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _pageController,
                              decoration: _inputDecoration(hintText: 'VD: 150'),
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),
                            _label(
                              'Nội dung ghi chú',
                              required: true,
                              right: Text(
                                '${_contentController.text.length}/5000',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _contentController,
                              maxLines: 9,
                              maxLength: 5000,
                              decoration: _inputDecoration(
                                hintText: 'Viết ý tưởng, trích dẫn, hoặc bất cứ điều gì',
                              ).copyWith(counterText: ''),
                              validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nội dung' : null,
                            ),

                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const OcrModal(),
                                );
                              },
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Chụp ảnh đoạn văn (OCR)'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ✅ FIX: Switch không bị đảo state 2 lần nữa
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFFC14D)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          setState(() => isFlashcard = !isFlashcard),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.help_outline, color: Color(0xFFB45309)),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tạo Flashcard',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Ghi chú này sẽ được đưa vào lịch ôn tập',
                                                  style: TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: isFlashcard,
                                    onChanged: (v) => setState(() => isFlashcard = v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Lưu ghi chú',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
