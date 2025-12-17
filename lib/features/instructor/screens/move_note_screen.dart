// File: lib/features/instructor/screens/move_note_screen.dart
import 'package:flutter/material.dart';

class MoveNoteScreen extends StatefulWidget {
  const MoveNoteScreen({super.key});

  @override
  State<MoveNoteScreen> createState() => _MoveNoteScreenState();
}

class _MoveNoteScreenState extends State<MoveNoteScreen> {
  // Danh sách sách giả lập
  final List<String> books = [
    'Atomic Habits',
    'Deep Work',
    'Thinking, Fast and Slow',
    'Nhà Giả Kim',
    'Đắc Nhân Tâm'
  ];

  // Sách đang được chọn (Mặc định là sách hiện tại)
  String selectedBook = 'Atomic Habits';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chuyển sang sách khác',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Danh sách sách (Radio List)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: books.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
                itemBuilder: (context, index) {
                  final bookName = books[index];
                  return RadioListTile<String>(
                    title: Text(
                      bookName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selectedBook == bookName ? const Color(0xFF155DFC) : const Color(0xFF101727),
                      ),
                    ),
                    value: bookName,
                    groupValue: selectedBook,
                    activeColor: const Color(0xFF155DFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (value) {
                      setState(() {
                        selectedBook = value!;
                      });
                    },
                  );
                },
              ),
            ),

            // 2. Footer Buttons (Hủy / Lưu)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD0D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Hủy', style: TextStyle(color: Color(0xFF354152), fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic chuyển sách (API) sẽ viết ở đây
                        Navigator.pop(context);

                        // Hiện thông báo thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã chuyển sang sách "$selectedBook"')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9810FA), // Màu tím theo thiết kế Figma
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Chuyển sách', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}