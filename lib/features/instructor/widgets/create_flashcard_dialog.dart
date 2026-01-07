import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class CreateFlashcardDialog extends StatefulWidget {
  final Note note;
  const CreateFlashcardDialog({super.key, required this.note});

  @override
  State<CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  final NoteService _service = NoteService();

  late final TextEditingController _qController;
  late final TextEditingController _aController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final bookTitle = _safeString(_tryGetBookTitle());
    final content = _safeString(_tryGetContent());

    _qController = TextEditingController(
      text: bookTitle.isNotEmpty
          ? 'Câu hỏi/Tiêu đề về: $bookTitle'
          : 'Câu hỏi/Tiêu đề về ghi chú này',
    );

    _aController = TextEditingController(text: content);
  }

  @override
  void dispose() {
    _qController.dispose();
    _aController.dispose();
    super.dispose();
  }

  String _getNoteId() => widget.note.id.toString().trim();

  Future<void> _create() async {
    final noteId = _getNoteId();
    final question = _qController.text.trim();
    final answer = _aController.text.trim();

    if (noteId.isEmpty) {
      _toast('Không tìm thấy id của ghi chú (note.id). Kiểm tra model Note.');
      return;
    }

    if (question.isEmpty || answer.isEmpty) {
      _toast('Vui lòng nhập đầy đủ Câu hỏi và Nội dung.');
      return;
    }

    setState(() => _saving = true);

    try {
      // ✅ FIX: createFlashcard dùng named required params
      await _service.createFlashcard(
        noteId: noteId,
        question: question,
        answer: answer,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // 🔥 báo màn cha reload
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('Tạo flashcard thất bại: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Helpers an toàn nếu model Note nullable/non-nullable khác nhau
  String _safeString(Object? v) => (v ?? '').toString().trim();

  Object? _tryGetBookTitle() {
    try {
      return widget.note.bookTitle;
    } catch (_) {
      return '';
    }
  }

  Object? _tryGetContent() {
    try {
      return widget.note.content;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo Flashcard',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chuyển đổi ghi chú thành thẻ học tập',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    tooltip: 'Đóng',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mặt trước (Câu hỏi)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _qController,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Nhập tiêu đề/câu hỏi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mặt sau (Nội dung ghi chú)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _aController,
                enabled: !_saving,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung trả lời / ghi chú',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saving ? null : _create,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Tạo Flashcard'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
