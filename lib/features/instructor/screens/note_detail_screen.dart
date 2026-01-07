import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../services/note_service.dart';

import 'edit_note_screen.dart';
import '../widgets/delete_options_sheet.dart';
import '../widgets/create_flashcard_dialog.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _noteService = NoteService();

  String _formatDateTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$hh:$mm  $dd/$mo/$yyyy';
  }

  String _buildShareText(Note note) {
    return '''
📚 Sách: ${note.bookTitle}
📄 Trang: ${note.pageNumber}

${note.content}
'''.trim();
  }

  Future<void> _copy(Note note) async {
    final text = _buildShareText(note);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép ghi chú')),
    );
  }

  Future<void> _share(Note note) async {
    final text = _buildShareText(note);
    await Share.share(
      text,
      subject: 'Ghi chú: ${note.bookTitle} (Trang ${note.pageNumber})',
    );
  }

  Future<void> _edit(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditNoteScreen(),
        settings: RouteSettings(arguments: {'note': note}),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _createFlashcard(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => CreateFlashcardDialog(note: note),
    );

    if (!mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo flashcard')),
      );
      setState(() {});
    }
  }

  Future<void> _delete(Note note) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const DeleteOptionsSheet(),
    );

    if (!mounted || choice == null) return;

    if (choice == 'soft_delete') {
      await _noteService.moveToTrash(note.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chuyển vào thùng rác')),
      );
    } else if (choice == 'hard_delete') {
      await _noteService.deletePermanently(note.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa vĩnh viễn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nhận note từ arguments (đúng flow feature)
    final args = ModalRoute.of(context)?.settings.arguments;
    Note? initialNote;

    if (args is Note) {
      initialNote = args;
    } else if (args is Map && args['note'] is Note) {
      initialNote = args['note'] as Note;
    }

    if (initialNote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết ghi chú')),
        body: const Center(child: Text('Không tìm thấy dữ liệu ghi chú')),
      );
    }

    // Realtime update (nếu NoteService có watchNoteById)
    return StreamBuilder<Note?>(
      stream: _noteService.watchNoteById(initialNote.id),
      builder: (context, snapshot) {
        final note = snapshot.data ?? initialNote!;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            leading: const BackButton(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // dải gradient dưới appbar để tạo hiệu ứng “card nổi”
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF155CFB), Color(0xFF432DD7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                        border: Border.all(
                          color: const Color(0xFFFFD22F),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text(
                                'Trang',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(width: 6),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFDE68A),
                                    ),
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
                          const Divider(height: 28),
                          Text(
                            note.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tạo/Cập nhật lúc: ${_formatDateTime(note.updatedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGrayButton(
                                  Icons.copy,
                                  'Sao chép',
                                  onTap: () => _copy(note),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGrayButton(
                                  Icons.share_outlined,
                                  'Chia sẻ',
                                  onTap: () => _share(note),
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
                        onTap: () => _edit(note),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        text: 'Tạo Flashcard học tập',
                        icon: Icons.lightbulb_outline,
                        bgColor: const Color(0xFFFFFBEB),
                        textColor: const Color(0xFF92400E),
                        iconColor: const Color(0xFFD97706),
                        borderColor: const Color(0xFFFDE68A),
                        onTap: () => _createFlashcard(note),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        text: 'Xóa ghi chú',
                        icon: Icons.delete_outline,
                        bgColor: const Color(0xFFFEF2F2),
                        textColor: const Color(0xFF991B1B),
                        iconColor: const Color(0xFFDC2626),
                        borderColor: const Color(0xFFFECACA),
                        onTap: () => _delete(note),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
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
