import 'package:flutter/material.dart';
import 'ocr_modal.dart';
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  final NoteService _noteService = NoteService();

  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? selectedBook;
  bool isFlashcard = false;
  bool _saving = false;

  // Map demo (giữ như nhánh feature). Nếu app bạn có list sách thật, bạn có thể thay sau.
  final Map<String, String> _bookIdMap = const {
    'Atomic Habits': 'book_flutter_01',
    'Deep Work': 'book_flutter_02',
  };

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
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF155DFC)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Future<void> _handleOCR() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OcrModal(),
    );

    if (!mounted) return;

    if (result != null && result is String && result.trim().isNotEmpty) {
      setState(() {
        if (_contentController.text.trim().isEmpty) {
          _contentController.text = result.trim();
        } else {
          _contentController.text = '${_contentController.text.trim()}\n${result.trim()}';
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    final pageNumber = int.tryParse(_pageController.text.trim()) ?? 0;

    // ✅ bookTitle chính là option dropdown user chọn
    final bookTitle = (selectedBook ?? '').trim();
    // ✅ bookId lấy theo map, fallback nếu thiếu
    final bookId = _bookIdMap[bookTitle] ?? 'book_flutter_01';

    setState(() => _saving = true);
    try {
      await _noteService.addNote(
        content: content,
        pageNumber: pageNumber,
        bookId: bookId,
        bookTitle: bookTitle.isEmpty ? 'Sách' : bookTitle,
        userId: 'test_user_001',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu Firestore: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ghi chú mới',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Chọn sách', isRequired: true),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(hintText: 'Chọn sách'),
                        value: selectedBook,
                        items: _bookIdMap.keys
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedBook = v),
                        validator: (value) =>
                            value == null ? 'Vui lòng chọn sách' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Số trang (tùy chọn)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pageController,
                        decoration: _inputDecoration(hintText: 'VD: 150'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final n = int.tryParse(value);
                            if (n == null || n <= 0) return 'Số trang không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Nội dung ghi chú', isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: _inputDecoration(hintText: 'Viết ý tưởng, trích dẫn...')
                            .copyWith(counterText: ""),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Vui lòng nhập nội dung';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleOCR,
                              icon: const Icon(Icons.document_scanner_outlined),
                              label: const Text('OCR'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => isFlashcard = !isFlashcard),
                              icon: Icon(
                                isFlashcard
                                    ? Icons.check_circle
                                    : Icons.quiz_outlined,
                              ),
                              label: const Text('Flashcard'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF155DFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                                fontWeight: FontWeight.bold,
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
    );
  }
}
