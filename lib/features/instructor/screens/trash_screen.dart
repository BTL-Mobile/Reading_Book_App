import 'package:flutter/material.dart';
import 'package:pht_04/models/note_model.dart';
import 'package:pht_04/services/note_service.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final NoteService _noteService = NoteService();

  // Hàm xử lý Khôi phục
  void _handleRestore(String noteId) async {
    await _noteService.restoreNote(noteId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã khôi phục ghi chú")));
    }
  }

  // Hàm xử lý Xóa vĩnh viễn
  void _handleDeleteForever(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa vĩnh viễn?"),
        content: const Text(
          "Hành động này không thể hoàn tác. Bạn có chắc chắn không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa luôn", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _noteService.deleteNotePermanently(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa vĩnh viễn ghi chú")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // Fix lỗi 2 header: Chỉ dùng 1 AppBar chuẩn
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Thùng rác",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cảnh báo màu vàng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFFFFFBEB),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Các ghi chú trong thùng rác sẽ tự động bị xóa vĩnh viễn sau 30 ngày",
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB45309).withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách ghi chú
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _noteService
                  .getTrashNotesStream(), // Gọi hàm lấy dữ liệu rác
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final trashNotes = snapshot.data ?? [];

                // Nếu thùng rác trống -> Hiện giao diện trống
                if (trashNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Thùng rác trống",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Các ghi chú đã xóa sẽ xuất hiện ở đây",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Nếu có dữ liệu -> Hiện danh sách
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trashNotes.length,
                  itemBuilder: (context, index) {
                    final note = trashNotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          note.bookTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Trang: ${note.pageNumber}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút Khôi phục
                            IconButton(
                              icon: const Icon(
                                Icons.restore,
                                color: Colors.green,
                              ),
                              tooltip: 'Khôi phục',
                              onPressed: () => _handleRestore(note.id!),
                            ),
                            // Nút Xóa vĩnh viễn
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              tooltip: 'Xóa vĩnh viễn',
                              onPressed: () => _handleDeleteForever(note.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
