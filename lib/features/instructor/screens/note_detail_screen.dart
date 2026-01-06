import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pht_04/models/note_model.dart';
import 'package:pht_04/services/note_service.dart';
import 'edit_note_screen.dart';
import '../widgets/move_note_dialog.dart';
import '../widgets/delete_options_sheet.dart';
import '../widgets/create_flashcard_dialog.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // Format ngày tháng (Giữ nguyên)
  String _formatDateTime(DateTime date) {
    return DateFormat('HH:mm EEEE, dd/MM/yyyy', 'vi').format(date);
  }

  // Xử lý xóa (Giữ nguyên)
  void _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text(
          "Bạn có chắc muốn chuyển ghi chú này vào thùng rác?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.note.id != null) {
      await NoteService().moveToTrash(widget.note.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã chuyển vào thùng rác")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Màu nền xám nhạt
      // --- PHẦN 1: HEADER (APPBAR) CHUẨN ---
      appBar: AppBar(
        elevation: 0,
        // Tạo màu gradient cho thanh Header
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155CFB), Color(0xFF432DD7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Chi tiết ghi chú',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),

      // --- PHẦN 2: NỘI DUNG (KHÔNG CÒN BỊ ĐÈ LÊN HEADER) ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Cách đều các lề
        child: Column(
          children: [
            // Thẻ hiển thị nội dung chính
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                // Viền vàng nhẹ
                border: Border.all(color: const Color(0xFFFFD22F), width: 1.5),
                // Đổ bóng nhẹ
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sách
                  Text(
                    note.bookTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Số trang
                  Row(
                    children: [
                      const Text(
                        'Trang',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        note.pageNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30, thickness: 1),

                  // Nội dung ghi chú
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ngày tạo
                  Text(
                    'Tạo lúc: ${_formatDateTime(note.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút Sao chép & Chia sẻ nằm gọn trong thẻ
                  Row(
                    children: [
                      Expanded(child: _buildGrayButton(Icons.copy, 'Sao chép')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGrayButton(
                          Icons.share_outlined,
                          'Chia sẻ',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Các nút chức năng bên dưới
            _buildActionButton(
              text: 'Chỉnh sửa ghi chú',
              icon: Icons.edit_outlined,
              bgColor: Colors.white,
              textColor: const Color(0xFF1F2937),
              iconColor: const Color(0xFF155DFC),
              borderColor: const Color(0xFFD1D5DB),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNoteScreen(note: note),
                  ),
                );
                setState(() {}); // Refresh lại trang sau khi sửa
              },
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              text: 'Chuyển sang sách khác',
              icon: Icons.move_to_inbox_outlined,
              bgColor: Colors.white,
              textColor: const Color(0xFF1F2937),
              iconColor: const Color(0xFF155DFC),
              borderColor: const Color(0xFFD1D5DB),
              onTap: () => showDialog(
                context: context,
                builder: (context) => const MoveNoteDialog(),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              text: 'Tạo Flashcard học tập',
              icon: Icons.lightbulb_outline,
              bgColor: const Color(0xFFFFFBEB),
              textColor: const Color(0xFF92400E),
              iconColor: const Color(0xFFD97706),
              borderColor: const Color(0xFFFDE68A),
              onTap: () => showDialog(
                context: context,
                builder: (context) => CreateFlashcardDialog(
                  noteContent: note.content,
                  bookTitle: note.bookTitle,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              text: 'Xóa ghi chú',
              icon: Icons.delete_outline,
              bgColor: const Color(0xFFFEF2F2),
              textColor: const Color(0xFF991B1B),
              iconColor: const Color(0xFFDC2626),
              borderColor: const Color(0xFFFECACA),
              onTap: _handleDelete,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget nút xám nhỏ (Sao chép/Chia sẻ)
  Widget _buildGrayButton(IconData icon, String text) {
    return InkWell(
      onTap: () {
        // Xử lý sao chép sau này
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4B5563)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget nút chức năng dài
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
