import 'package:flutter/material.dart';

class EditNoteBottomSheetKey extends StatefulWidget {
  const EditNoteBottomSheetKey({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditNoteBottomSheetKey(),
    );
  }

  @override
  State<EditNoteBottomSheetKey> createState() =>
      _EditNoteBottomSheetKeyState();
}

class _EditNoteBottomSheetKeyState extends State<EditNoteBottomSheetKey> {
  final _pageController = TextEditingController(text: '15');
  final _contentController = TextEditingController();
  bool createFlashcard = true;

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: 'Chỉnh sửa ghi chú',
                  onClose: () => Navigator.pop(context),
                ),
                const Divider(height: 24),

                _BookInfoBox(bookName: 'Atomic Habits'),

                const SizedBox(height: 18),
                const _Label(text: 'Số trang (tùy chọn)'),
                const SizedBox(height: 10),
                _TextFieldBox(
                  controller: _pageController,
                  hintText: '',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),
                _OutlineActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Thêm văn bản từ ảnh (OCR)',
                  onTap: () {
                    // TODO: mở OCR bottom sheet
                  },
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    const _LabelRequired(text: 'Nội dung ghi chú'),
                    const Spacer(),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _contentController,
                      builder: (_, value, __) {
                        return Text(
                          '${value.text.length}/500',
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _MultilineBox(
                  controller: _contentController,
                  hintText: 'Viết ý tưởng, trích dẫn, hoặc bất cứ điều gì',
                  maxLength: 500,
                ),

                const SizedBox(height: 16),
                _FlashcardBox(
                  enabled: createFlashcard,
                  onToggle: (v) => setState(() => createFlashcard = v),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _BottomButton(
                        label: 'Hủy',
                        filled: false,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BottomButton(
                        label: 'Lưu thay đổi',
                        filled: true,
                        onTap: () {
                          // TODO: gọi update note
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= WIDGETS ================= */

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _TopBar({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
          splashRadius: 20,
        ),
      ],
    );
  }
}

class _BookInfoBox extends StatelessWidget {
  final String bookName;
  const _BookInfoBox({required this.bookName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Sách: $bookName',
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF475467),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LabelRequired extends StatelessWidget {
  final String text;
  const _LabelRequired({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _MultilineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;

  const _MultilineBox({
    required this.controller,
    required this.hintText,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 6,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _FlashcardBox extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _FlashcardBox({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!enabled),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7CC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.orange,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tạo Flashcard',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ghi chú này sẽ được đưa vào lịch ôn tập',
                    style: TextStyle(color: Colors.black54),
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

class _BottomButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label, style: const TextStyle(fontSize: 18)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(label, style: const TextStyle(fontSize: 18)),
            ),
    );
  }
}
