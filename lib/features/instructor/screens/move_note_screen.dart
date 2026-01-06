import 'package:flutter/material.dart';

class MoveNoteDialog extends StatefulWidget {
  const MoveNoteDialog({super.key});

  @override
  State<MoveNoteDialog> createState() => _MoveNoteDialogState();
}

class _MoveNoteDialogState extends State<MoveNoteDialog> {
  final List<String> books = [
    'Deep Work',
    'Thinking, Fast and Slow',
    'Nhà Giả Kim',
    'Đắc Nhân Tâm'
  ];

  String? selectedBook;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chuyển ghi chú sang sách khác',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101727),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE585)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFF963B00), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ghi chú sẽ được chuyển sang cuốn sách mới và không còn liên kết với cuốn sách hiện tại.',
                      style: TextStyle(color: Color(0xFF963B00), fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Cuốn sách hiện tại',
              style: TextStyle(color: Color(0xFF354152), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8), // Thêm const tại dòng 62
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Atomic Habits',
                style: TextStyle(color: Color(0xFF354152), fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            const Row(
              children: [
                Text(
                  'Chuyển sang cuốn sách',
                  style: TextStyle(color: Color(0xFF354152), fontWeight: FontWeight.w500),
                ),
                Text(' *', style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: '-- Chọn cuốn sách --',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DB)),
                ),
              ),
              value: selectedBook,
              items: books.map((book) {
                return DropdownMenuItem(value: book, child: Text(book));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBook = value;
                });
              },
            ),
            const SizedBox(height: 32), // Thêm const tại dòng 99

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD0D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Hủy', style: TextStyle(color: Color(0xFF354152), fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedBook == null
                        ? null
                        : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã chuyển sang: $selectedBook')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF155DFC),
                      disabledBackgroundColor: const Color(0xFFD1D5DC),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Chuyển', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}