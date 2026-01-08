import 'package:flutter/material.dart';
import '../../services/flashcard_service.dart';

class CreateFlashcardDialog extends StatefulWidget {
  const CreateFlashcardDialog({super.key});

  @override
  State<CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  final _service = FlashcardService();

  // ✅ thêm bookId để lọc theo bookId
  final _bookId = TextEditingController();

  final _title = TextEditingController(); // bookTitle / chủ đề
  final _front = TextEditingController();
  final _back = TextEditingController();

  bool _saving = false;

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE07A00), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _bookId.dispose();
    _title.dispose();
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;

    final bookId = _bookId.text.trim();
    final bookTitle = _title.text.trim();
    final front = _front.text.trim();
    final back = _back.text.trim();

    // ✅ validate
    if (bookId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập BookId (vd: book_flutter_01)')),
      );
      return;
    }
    if (bookTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Tên sách/Chủ đề')),
      );
      return;
    }
    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ Mặt trước và Mặt sau')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // ✅ tạo thẳng vào /flashcards theo bookId
      await _service.addCard(
        bookId,
        front,
        back,
        bookTitle: bookTitle,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo thẻ: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tạo thẻ mới',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ thêm BookId
            TextField(
              controller: _bookId,
              decoration: _dec('BookId (vd: book_flutter_01)'),
            ),
            const SizedBox(height: 14),

            TextField(controller: _title, decoration: _dec('Tên sách/ Chủ đề')),
            const SizedBox(height: 14),

            TextField(
              controller: _front,
              maxLines: 5,
              decoration: _dec('Mặt trước'),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _back,
              maxLines: 5,
              decoration: _dec('Mặt sau'),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07A00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    'Tạo thẻ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
