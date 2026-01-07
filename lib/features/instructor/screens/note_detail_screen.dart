import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../services/note_service.dart';

import 'edit_note_screen.dart';
import '../widgets/delete_options_sheet.dart';
import '../widgets/create_flashcard_dialog.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$hh:$mm  $dd/$mo/$yyyy';
  }

  // ✅ Text để copy / share
  String _buildShareText(Note note) {
    return '''
📚 Sách: ${note.bookTitle}
📄 Trang: ${note.pageNumber}

${note.content}
'''.trim();
  }

  @override
  Widget build(BuildContext context) {
    final initialNote = ModalRoute.of(context)?.settings.arguments as Note?;
    if (initialNote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết ghi chú')),
        body: const Center(child: Text('Không tìm thấy dữ liệu ghi chú')),
      );
    }

    final noteService = NoteService();

    return StreamBuilder<Note?>(
      stream: noteService.watchNoteById(initialNote.id),
      builder: (context, snapshot) {
        final note = snapshot.data ?? initialNote;

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
            title: const Text(
              'Chi tiết ghi chú',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.bookTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Trang', style: TextStyle(color: Color(0xFF6B7280))),
                              const SizedBox(width: 4),
                              Text(
                                '${note.pageNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (note.isConverted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Text(
                                    'Flashcard',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(
                            note.content,
                            style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tạo/Cập nhật lúc: ${_formatDateTime(note.updatedAt)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 24),

                          if (note.isConverted)
                            StreamBuilder<Map<String, String>?>(
                              stream: noteService.watchLatestFlashcardForNote(note.id),
                              builder: (context, fcSnap) {
                                final fc = fcSnap.data;
                                final question = (fc?['question'] ?? '').trim();

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.lightbulb, color: Color(0xFFD97706)),
                                          SizedBox(width: 8),
                                          Text(
                                            'Flashcard đang hoạt động',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (question.isNotEmpty) ...[
                                        const Text(
                                          'Câu hỏi / Tiêu đề:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF92400E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          question,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFB45309),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else
                                        const Text(
                                          'Ghi chú này đã được chuyển thành Flashcard',
                                          style: TextStyle(fontSize: 13, color: Color(0xFFB45309)),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          if (note.isConverted) const SizedBox(height: 20),

                          // ✅ SỬA: bật Sao chép + Chia sẻ
                          Row(
                            children: [
                              Expanded(
                                child: _buildGrayButton(
                                  Icons.copy,
                                  'Sao chép',
                                  onTap: () async {
                                    final text = _buildShareText(note);
                                    await Clipboard.setData(ClipboardData(text: text));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã sao chép ghi chú')),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGrayButton(
                                  Icons.share_outlined,
                                  'Chia sẻ',
                                  onTap: () async {
                                    final text = _buildShareText(note);
                                    await Share.share(
                                      text,
                                      subject: 'Ghi chú: ${note.bookTitle} (Trang ${note.pageNumber})',
                                    );
                                  },
                                ),
                              ),
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
                              builder: (_) => const EditNoteScreen(),
                              settings: RouteSettings(
                                arguments: {'note': note},
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildActionButton(
                        text: 'Tạo Flashcard học tập',
                        icon: Icons.lightbulb_outline,
                        bgColor: const Color(0xFFFFFBEB),
                        textColor: const Color(0xFF92400E),
                        iconColor: const Color(0xFFD97706),
                        borderColor: const Color(0xFFFDE68A),
                        onTap: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => CreateFlashcardDialog(note: note),
                          );
                          if (ok == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã tạo flashcard')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildActionButton(
                        text: 'Xóa ghi chú',
                        icon: Icons.delete_outline,
                        bgColor: const Color(0xFFFEF2F2),
                        textColor: const Color(0xFF991B1B),
                        iconColor: const Color(0xFFDC2626),
                        borderColor: const Color(0xFFFECACA),
                        onTap: () async {
                          final choice = await showModalBottomSheet<String>(
                            context: context,
                            builder: (_) => const DeleteOptionsSheet(),
                          );

                          if (choice == null) return;

                          if (choice == 'soft_delete') {
                            await noteService.moveToTrash(note.id);
                            if (!context.mounted) return;
                            Navigator.of(context).pop(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã chuyển vào thùng rác')),
                            );
                          } else if (choice == 'hard_delete') {
                            await noteService.deletePermanently(note.id);
                            if (!context.mounted) return;
                            Navigator.of(context).pop(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa vĩnh viễn')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrayButton(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
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
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF374151)),
            ),
          ],
        ),
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
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
