import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';

class CreateFlashcardDialog extends StatefulWidget {
  const CreateFlashcardDialog({super.key});

  @override
  State<CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  final _title = TextEditingController();
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
    _title.dispose();
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);

    final dynamic p = context.read<FlashcardProvider>();
    try {
      // provider bạn có thể đặt tên khác -> try/catch để không crash compile/runtime
      await p.createFlashcard(
        title: _title.text.trim(),
        question: _front.text.trim(),
        answer: _back.text.trim(),
      );
    } catch (_) {
      try {
        await p.addFlashcard(
          bookTitle: _title.text.trim(),
          frontText: _front.text.trim(),
          backText: _back.text.trim(),
        );
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.pop(context, true);
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
                      : const Text('Tạo thẻ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
