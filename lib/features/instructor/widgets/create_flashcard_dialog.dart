import 'package:flutter/material.dart';

class CreateFlashcardDialog extends StatefulWidget {
  final String noteContent;
  final String bookTitle;

  const CreateFlashcardDialog({super.key, required this.noteContent, required this.bookTitle});

  @override
  State<CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  late TextEditingController _frontController;
  late TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    // Tự động điền theo đặc tả 1.5.3
    _frontController = TextEditingController(text: "Câu hỏi/Tiêu đề về: ${widget.bookTitle}");
    _backController = TextEditingController(text: widget.noteContent);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo Flashcard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Chuyển đổi ghi chú thành thẻ học tập', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),

            // Mặt trước
            const Text('Mặt trước (Câu hỏi)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _frontController,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 16),

            // Mặt sau
            const Text('Mặt sau (Nội dung ghi chú)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _backController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Logic lưu flashcard
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo Flashcard thành công!')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                  child: const Text('Tạo Flashcard', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}