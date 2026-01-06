import 'package:flutter/material.dart';
import '../../services/community_service.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _bookTitleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  String _selectedType = 'rating'; // Mặc định là đánh giá
  int _rating = 5;
  bool _isLoading = false;

  // Hàm xử lý khi bấm nút Đăng
  void _handlePost() async {
    if (_bookTitleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên sách")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gọi Service để lưu vào Firestore
      await CommunityService().createPost(
        bookTitle: _bookTitleCtrl.text,
        type: _selectedType,
        content: _contentCtrl.text,
        rating: _selectedType == 'rating' ? _rating : null,
      );

      if (mounted) {
        Navigator.pop(context); // Đóng modal sau khi thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng bài thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding này giúp Modal bị đẩy lên khi bàn phím hiện ra
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // Column mới là nơi chứa mainAxisSize: MainAxisSize.min
        child: Column(
          mainAxisSize: MainAxisSize.min, // Giúp modal chỉ cao vừa đủ nội dung
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Chia sẻ hoạt động",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Chọn loại bài viết (Chips)
            Row(
              children: [
                _buildTypeChip('rating', "Đánh giá", Icons.star),
                const SizedBox(width: 8),
                _buildTypeChip('note', "Ghi chú", Icons.edit_note),
                const SizedBox(width: 8),
                _buildTypeChip('wishlist', "Muốn đọc", Icons.bookmark_add),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Nhập tên sách
            TextField(
              controller: _bookTitleCtrl,
              decoration: const InputDecoration(
                labelText: "Tên cuốn sách",
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Nhập nội dung
            TextField(
              controller: _contentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _selectedType == 'rating'
                    ? "Cảm nghĩ của bạn..."
                    : "Trích dẫn / Ghi chú...",
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),

            // 4. Chọn sao (Chỉ hiện khi là Rating)
            if (_selectedType == 'rating') ...[
              const SizedBox(height: 16),
              const Text(
                "Đánh giá:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 24),

            // 5. Nút Đăng
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        "Đăng bài",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Nút chọn loại (Chip)
  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
