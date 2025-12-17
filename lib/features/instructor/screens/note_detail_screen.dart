import 'package:flutter/material.dart';
import 'edit_note_screen.dart';
// Import các widget mới
import '../widgets/move_note_dialog.dart';
import '../widgets/delete_options_sheet.dart';
import '../widgets/create_flashcard_dialog.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF155CFB), Color(0xFF432DD7)]),
          ),
        ),
        title: const Text('Chi tiết ghi chú', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF155CFB), Color(0xFF432DD7)]),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD22F), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Atomic Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Text('Trang', style: TextStyle(color: Color(0xFF6B7280))),
                          SizedBox(width: 4),
                          Text('15', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        ],
                      ),
                      const Divider(height: 30),
                      const Text(
                        'Thói quen tốt là nền tảng cho sự thành công. Quy tắc 1%: Cải thiện mỗi ngày 1% sẽ tạo ra sự khác biệt lớn sau 1 năm.',
                        style: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tạo lúc: lúc 07:00 Thứ Bảy, 16 tháng 11, 2024', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.lightbulb, color: Color(0xFFD97706)),
                                SizedBox(width: 8),
                                Text('Flashcard đang hoạt động', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('Ghi chú này đang được đưa vào lịch ôn tập', style: TextStyle(fontSize: 13, color: Color(0xFFB45309))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: _buildGrayButton(Icons.copy, 'Sao chép')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGrayButton(Icons.share_outlined, 'Chia sẻ')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionButton(
                    text: 'Chuyển thành Flashcard',
                    icon: Icons.style,
                    bgColor: const Color(0xFFFFFBEB),
                    textColor: const Color(0xFFD97706),
                    iconColor: const Color(0xFFD97706),
                    borderColor: const Color(0xFFFCD34D),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => const CreateFlashcardDialog(
                              noteContent: "Nội dung ghi chú...",
                              bookTitle: "Atomic Habits"
                          )
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    text: 'Chỉnh sửa',
                    icon: Icons.edit_outlined,
                    bgColor: const Color(0xFF155DFC),
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    borderColor: Colors.transparent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditNoteScreen())),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    text: 'Chuyển sang sách khác',
                    icon: Icons.arrow_forward,
                    bgColor: const Color(0xFFF3E8FF),
                    textColor: const Color(0xFF9333EA),
                    iconColor: const Color(0xFF9333EA),
                    borderColor: const Color(0xFFE9D5FF),
                    onTap: () => showDialog(context: context, builder: (context) => const MoveNoteDialog()),
                  ),
                  const SizedBox(height: 30),

                  // Nút Xóa mới (Mở BottomSheet)
                  _buildActionButton(
                    text: 'Xóa ghi chú',
                    icon: Icons.delete_outline,
                    bgColor: const Color(0xFFFEF2F2),
                    textColor: const Color(0xFFDC2626),
                    iconColor: const Color(0xFFDC2626),
                    borderColor: const Color(0xFFFECACA),
                    onTap: () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const DeleteOptionsSheet(),
                      );

                      if (result != null && context.mounted) {
                        Navigator.pop(context); // Đóng màn hình chi tiết
                        if (result == 'soft_delete') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chuyển vào thùng rác')));
                        } else if (result == 'hard_delete') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa vĩnh viễn')));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGrayButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4B5563)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        ],
      ),
    );
  }

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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}