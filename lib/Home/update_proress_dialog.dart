import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart'; // 1. Import Service

class UpdateProgressDialog extends StatefulWidget {
  final Book book;
  const UpdateProgressDialog({super.key, required this.book});

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  late TextEditingController _pageController;
  final BookService _bookService = BookService(); // 2. Khởi tạo Service
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    // 3. Lấy số trang hiện tại của sách để hiển thị (thay vì số 150 cứng)
    _pageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ LƯU ---
  Future<void> _handleSave() async {
    // Lấy số từ ô nhập
    int? newPage = int.tryParse(_pageController.text);

    if (newPage == null || newPage < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số trang hợp lệ!")),
      );
      return;
    }

    // Kiểm tra logic: Không được đọc quá tổng số trang (nếu tổng trang > 0)
    if (widget.book.totalPages > 0 && newPage > widget.book.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Số trang không thể lớn hơn ${widget.book.totalPages}!",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Bật loading

    try {
      // Gọi Service cập nhật
      // Lưu ý: Giữ nguyên totalPages cũ, chỉ cập nhật currentPage mới
      await _bookService.updateReadingProgress(
        widget.book.id,
        newPage,
        widget.book.totalPages,
      );

      if (mounted) {
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật tiến độ thành công!"),
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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cập nhật tiến độ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Hiển thị tổng số trang để người dùng biết
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Trang hiện tại",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                if (widget.book.totalPages > 0)
                  Text(
                    "/ ${widget.book.totalPages}", // Hiện tổng trang bên cạnh cho dễ nhìn
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),

            const SizedBox(height: 8),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2D68FF),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
                      onPressed: _isLoading
                          ? null
                          : _handleSave, // Khóa nút khi đang lưu
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D68FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      // Hiển thị vòng xoay nếu đang loading
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
    );
  }
}
