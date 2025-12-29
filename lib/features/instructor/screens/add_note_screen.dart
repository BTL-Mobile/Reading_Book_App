import 'package:flutter/material.dart';
import 'ocr_modal.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  String? selectedBook;
  bool isFlashcard = false;

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
        title: const Text('Ghi chú mới', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Chọn sách', isRequired: true),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(hintText: 'Chọn sách'),
                      value: selectedBook,
                      items: ['Atomic Habits', 'Deep Work'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => selectedBook = v),
                      validator: (value) => value == null ? 'Vui lòng chọn sách' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Số trang (tùy chọn)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pageController,
                      decoration: _inputDecoration(hintText: 'VD: 150'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) return 'Số trang không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final res = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const OcrModal(),
                          );
                          if (res != null && res is String) {
                            setState(() => _contentController.text = res);
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF155DFC)),
                        label: const Text('Chụp ảnh đoạn văn (OCR)', style: TextStyle(color: Color(0xFF155DFC), fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8DC5FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Nội dung ghi chú', isRequired: true),
                        Text('${_contentController.text.length}/5000', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 8,
                      maxLength: 5000,
                      decoration: _inputDecoration(hintText: 'Viết ý tưởng, trích dẫn...').copyWith(counterText: ""),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nội dung ghi chú không được để trống';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24), // Đã thêm const tại dòng 126

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column( // Thêm const cho Column
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tạo Flashcard', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                              SizedBox(height: 4),
                              Text('Tự động tạo flashcard từ ghi chú này', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            ],
                          ),
                          Switch(
                            value: isFlashcard,
                            activeColor: const Color(0xFFD97706),
                            onChanged: (val) => setState(() => isFlashcard = val),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Hủy', style: TextStyle(color: Color(0xFF374151))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu ghi chú thành công!')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF155DFC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Lưu ghi chú', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600, fontSize: 14),
        children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}