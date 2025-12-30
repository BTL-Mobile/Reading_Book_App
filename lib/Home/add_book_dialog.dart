import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import 'google_book_search_screen.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final BookService _bookService = BookService();

  // Khởi tạo Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController =
      TextEditingController(); // Controller cho thể loại
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();

  int _selectedShelf = 0; // 0: Muốn đọc, 1: Đang đọc, 2: Đã đọc
  bool _isLoading = false;

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tên sách!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Xác định trạng thái
      String status = 'want_to_read';
      if (_selectedShelf == 1) status = 'reading';
      if (_selectedShelf == 2) status = 'read';

      final newBook = Book(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isEmpty
            ? "Chưa cập nhật"
            : _authorController.text.trim(),
        imageUrl: _imageController.text.trim().isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageController.text.trim(),
        description: _descriptionController.text.trim(),

        // Lấy category từ ô nhập liệu
        category: _categoryController.text.trim().isEmpty
            ? "Khác"
            : _categoryController.text.trim(),

        status: status,
        content: '',
        totalPages: int.tryParse(_totalPagesController.text.trim()) ?? 0,
        currentPage: 0,
      );

      await _bookService.addBook(newBook);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm sách thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose(); // Dispose category controller
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thêm sách mới",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      // Mở màn hình tìm kiếm và chờ kết quả trả về
                      final Book? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoogleBookSearchScreen(),
                        ),
                      );

                      // Nếu có kết quả (người dùng đã chọn sách), điền vào các ô
                      if (result != null) {
                        setState(() {
                          _titleController.text = result.title;
                          _authorController.text = result.author;
                          _imageController.text = result.imageUrl;
                          _descriptionController.text = result.description;
                          _categoryController.text = result.category;
                          // content thì Google không có nên vẫn để trống để nhập tay sau
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.travel_explore,
                      color: Colors.blue,
                    ), // Icon quả địa cầu
                    label: const Text("Google Auto"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form nhập liệu
              _buildTextField("Tên sách *", _titleController, Icons.book),
              const SizedBox(height: 12),
              _buildTextField(
                "Tác giả",
                _authorController,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),

              // Ô NHẬP THỂ LOẠI (Nhập tay)
              _buildTextField(
                "Thể loại",
                _categoryController,
                Icons.category_outlined,
              ),

              const SizedBox(height: 12),
              _buildTextField(
                "Link ảnh bìa (URL)",
                _imageController,
                Icons.image_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                "Mô tả ngắn",
                _descriptionController,
                Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // ...
              _buildTextField(
                "Tổng số trang",
                _totalPagesController,
                Icons.numbers,
                maxLines: 1,
              ),
              const SizedBox(height: 12),

              // Chọn Kệ sách
              const Text(
                "Kệ sách",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 8.0 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedShelf = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedShelf == i
                                  ? const Color(0xFF2D68FF)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ["Muốn đọc", "Đang đọc", "Đã đọc"][i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedShelf == i
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D68FF),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Lưu",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
