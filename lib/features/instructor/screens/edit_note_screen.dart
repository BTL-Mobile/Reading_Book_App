import 'package:flutter/material.dart';
import 'ocr_modal.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _contentController;
  String? selectedBook;
  final List<String> books = ['Atomic Habits', 'Deep Work'];

  @override
  void initState() {
    super.initState();
    selectedBook = 'Atomic Habits';
    _contentController = TextEditingController(text: 'Thói quen tốt là nền tảng cho sự thành công...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Chỉnh sửa ghi chú', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      value: selectedBook,
                      items: books.map((book) => DropdownMenuItem(value: book, child: Text(book))).toList(),
                      onChanged: (value) => setState(() => selectedBook = value),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                              context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const OcrModal());
                          if (result != null && result is String) setState(() => _contentController.text += "\n$result");
                        },
                        icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF155DFC)),
                        label: const Text('Thêm văn bản từ ảnh (OCR)'),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF155DFC), side: const BorderSide(color: Color(0xFF8DC5FF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: 'Nội dung', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF155DFC), minimumSize: const Size(double.infinity, 50)),
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}