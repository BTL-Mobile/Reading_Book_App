import 'package:flutter/material.dart';
import 'ocr_modal.dart'; // Giữ lại tính năng OCR nếu bạn có file này
import 'package:pht_04/services/note_service.dart';
import 'package:pht_04/models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  // Khởi tạo các controller để nhập liệu
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bookTitleController.dispose();
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Hàm xử lý Lưu ghi chú mới
  Future<void> _handleSave() async {
    final title = _bookTitleController.text.trim();
    final page = _pageController.text.trim();
    final content = _contentController.text.trim();

    // Kiểm tra dữ liệu trống
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Tên sách và Nội dung')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Tạo model ghi chú mới
    final newNote = NoteModel(
      id: null, // Firestore sẽ tự sinh ID
      bookTitle: title,
      pageNumber: page.isEmpty ? "Chưa rõ" : page,
      content: content,
      hasFlashcard: false, // Mặc định chưa có flashcard
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    try {
      // Gọi Service để lưu lên Firebase
      await NoteService().addNote(newNote);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm ghi chú thành công')),
        );
        Navigator.pop(context); // Quay về màn hình danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Thêm ghi chú mới',
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
                    // 1. Ô nhập Tên Sách (TextField thay vì Dropdown)
                    TextFormField(
                      controller: _bookTitleController,
                      decoration: InputDecoration(
                        labelText: 'Tên sách',
                        hintText: 'Nhập tên sách...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.book_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    // 2. Ô nhập Số trang
                    TextFormField(
                      controller: _pageController,
                      decoration: InputDecoration(
                        labelText: 'Số trang',
                        hintText: 'VD: Trang 15',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.bookmark_border,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Nút OCR (Quét ảnh)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Gọi Modal OCR để quét văn bản
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const OcrModal(),
                          );
                          // Nếu có kết quả trả về thì cộng dồn vào nội dung
                          if (result != null && result is String) {
                            setState(
                              () => _contentController.text += "\n$result",
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF155DFC),
                        ),
                        label: const Text('Thêm văn bản từ ảnh (OCR)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF155DFC),
                          side: const BorderSide(color: Color(0xFF8DC5FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Ô nhập Nội dung chính
                    TextFormField(
                      controller: _contentController,
                      maxLines: 12,
                      decoration: InputDecoration(
                        hintText: 'Nội dung ghi chú...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            // Nút Lưu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lưu ghi chú',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
