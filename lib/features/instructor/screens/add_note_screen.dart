import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ocr_modal.dart';
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  final NoteService _noteService = NoteService();

  // ✅ chọn sách thật từ Firestore collection('books')
  String? selectedBookId;
  String? selectedBookTitle;

  bool isFlashcard = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {}); // counter 0/5000 update realtime
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
        borderSide: const BorderSide(color: Color(0xFF155DFC)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  // ✅ Lấy danh sách sách thật từ root collection('books') (khớp BookService của bạn)
  Stream<List<_BookPick>> _watchBooks() {
    return FirebaseFirestore.instance.collection('books').snapshots().map(
          (snap) => snap.docs.map((d) {
        final data = d.data();
        final title = (data['title'] ?? 'Sách') as String;
        return _BookPick(id: d.id, title: title);
      }).toList(),
    );
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    final pageNumber = int.tryParse(_pageController.text.trim()) ?? 0;

    final bookId = (selectedBookId ?? '').trim();
    final bookTitle = (selectedBookTitle ?? '').trim();

    setState(() => _saving = true);
    try {
      await _noteService.addNote(
        content: content,
        pageNumber: pageNumber,
        bookId: bookId.isEmpty ? 'unknown_book' : bookId,
        bookTitle: bookTitle.isEmpty ? 'Sách' : bookTitle,
        userId: 'test_user_001', // nếu bạn chưa dùng auth thì giữ như vậy
        isFlashcard: isFlashcard, // ✅ QUAN TRỌNG: lưu flag flashcard
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
    final counterText = '${_contentController.text.length}/5000';

    // ✅ nền đen + panel trắng bo góc giống ảnh
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ghi chú mới',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
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

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Chọn sách', isRequired: true),
                            const SizedBox(height: 8),

                            // Dropdown chọn sách
                            StreamBuilder<List<_BookPick>>(
                              stream: _watchBooks(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    child: Text(
                                      'Lỗi tải sách: ${snapshot.error}',
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    child: const Text(
                                      'Đang tải danh sách sách...',
                                    ),
                                  );
                                }

                                final books =
                                    snapshot.data ?? const <_BookPick>[];

                                if (books.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    child: const Text(
                                      'Bạn chưa có sách nào. Hãy thêm sách trước.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  );
                                }

                                return DropdownButtonFormField<String>(
                                  decoration:
                                  _inputDecoration(hintText: 'Chọn sách'),
                                  value: selectedBookId,
                                  items: books
                                      .map(
                                        (b) => DropdownMenuItem(
                                      value: b.id,
                                      child: Text(
                                        b.title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (id) {
                                    final picked =
                                    books.firstWhere((x) => x.id == id);
                                    setState(() {
                                      selectedBookId = picked.id;
                                      selectedBookTitle = picked.title;
                                    });
                                  },
                                  validator: (value) =>
                                  value == null ? 'Vui lòng chọn sách' : null,
                                );
                              },
                            ),

                            const SizedBox(height: 18),
                            _buildLabel('Số trang (tùy chọn)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _pageController,
                              decoration: _inputDecoration(hintText: 'VD: 150'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final n = int.tryParse(value);
                                  if (n == null || n <= 0) {
                                    return 'Số trang không hợp lệ';
                                  }
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // OCR full width
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const OcrModal(),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text(
                                  'Chụp ảnh đoạn văn (OCR)',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF93C5FD),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Label + counter
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabel(
                                    'Nội dung ghi chú',
                                    isRequired: true,
                                  ),
                                ),
                                Text(
                                  counterText,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _contentController,
                              maxLines: 8,
                              maxLength: 5000,
                              decoration: _inputDecoration(
                                hintText:
                                'Viết ý tưởng, trích dẫn, hoặc bất cứ điều gì',
                              ).copyWith(counterText: ''),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Vui lòng nhập nội dung';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Flashcard card (toggle)
                            InkWell(
                              onTap: () =>
                                  setState(() => isFlashcard = !isFlashcard),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isFlashcard
                                          ? Icons.check_circle
                                          : Icons.quiz_outlined,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tạo Flashcard',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Ghi chú này sẽ được đưa vào lịch ôn tập',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed:
                              _saving ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF155DFC),
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
                                  fontWeight: FontWeight.w800,
                                ),
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

class _BookPick {
  final String id;
  final String title;
  const _BookPick({required this.id, required this.title});
}
