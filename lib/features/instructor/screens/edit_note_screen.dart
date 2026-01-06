import 'package:flutter/material.dart';
import 'ocr_modal.dart';
import 'package:pht_04/services/note_service.dart';
import 'package:pht_04/models/note_model.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note; // 1. Nhận dữ liệu ghi chú cần sửa

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _bookTitleController;
  late TextEditingController _pageController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 2. Điền dữ liệu cũ vào các ô nhập
    _bookTitleController = TextEditingController(text: widget.note.bookTitle);
    _pageController = TextEditingController(text: widget.note.pageNumber);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 3. Hàm xử lý cập nhật
  Future<void> _handleUpdate() async {
    final title = _bookTitleController.text.trim();
    final page = _pageController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sách và nội dung')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Tạo object mới giữ nguyên ID và Ngày tạo
    final updatedNote = NoteModel(
      id: widget.note.id,
      bookTitle: title,
      pageNumber: page,
      content: content,
      hasFlashcard: widget.note.hasFlashcard,
      createdAt: widget.note.createdAt,
      isDeleted: false,
    );

    try {
      await NoteService().updateNote(updatedNote);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
        Navigator.pop(context); // Về màn hình chi tiết (đã refresh)
        Navigator.pop(context); // Về màn hình danh sách (để refresh list)
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
                    // Tên Sách (Đổi thành TextField để hỗ trợ mọi tên sách từ DB)
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
                    ),
                    const SizedBox(height: 16),

                    // Số trang (Thêm mới vì NoteModel có trường này)
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

                    // Nút OCR (Giữ nguyên logic của bạn)
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

                    // Nội dung ghi chú
                    TextFormField(
                      controller: _contentController,
                      maxLines: 12, // Tăng độ cao để dễ nhìn
                      decoration: InputDecoration(
                        hintText: 'Nội dung ghi chú...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nút Lưu thay đổi
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lưu thay đổi',
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
