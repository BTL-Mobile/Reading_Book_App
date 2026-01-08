import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';

class EditFlashcardDialog extends StatefulWidget {
  final dynamic card;
  const EditFlashcardDialog({super.key, required this.card});

  @override
  State<EditFlashcardDialog> createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<EditFlashcardDialog> {
  late final TextEditingController _front;
  late final TextEditingController _back;
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

  String _safe(String Function() getter, {String fallback = ''}) {
    try {
      return getter().toString();
    } catch (_) {
      return fallback;
    }
  }

  @override
  void initState() {
    super.initState();
    _front = TextEditingController(text: _safe(() => widget.card.frontText, fallback: _safe(() => widget.card.question)));
    _back = TextEditingController(text: _safe(() => widget.card.backText, fallback: _safe(() => widget.card.answer)));
  }

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final dynamic p = context.read<FlashcardProvider>();
    try {
      await p.updateFlashcard(
        id: widget.card.id,
        question: _front.text.trim(),
        answer: _back.text.trim(),
      );
    } catch (_) {
      try {
        await p.editFlashcard(
          widget.card.id,
          _front.text.trim(),
          _back.text.trim(),
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
                'Chỉnh sửa thẻ',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _front, maxLines: 4, decoration: _dec('Mặt trước')),
            const SizedBox(height: 14),
            TextField(controller: _back, maxLines: 5, decoration: _dec('Mặt sau')),
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
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Lưu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
