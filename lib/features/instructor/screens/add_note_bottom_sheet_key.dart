import 'package:flutter/material.dart';

class AddNoteBottomSheetKey extends StatefulWidget {
  const AddNoteBottomSheetKey({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddNoteBottomSheetKey(),
    );
  }

  @override
  State<AddNoteBottomSheetKey> createState() => _AddNoteBottomSheetKeyState();
}

class _AddNoteBottomSheetKeyState extends State<AddNoteBottomSheetKey> {
  final _bookController = TextEditingController();
  final _pageController = TextEditingController();
  final _contentController = TextEditingController();

  bool createFlashcard = false;

  @override
  void dispose() {
    _bookController.dispose();
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
                  title: 'Ghi chú mới',
                  onClose: () => Navigator.pop(context),
                ),
                const Divider(height: 24),

                const SizedBox(height: 4),
                _LabelRequired(text: 'Chọn sách'),
                const SizedBox(height: 10),
                _TextFieldBox(
                  controller: _bookController,
                  hintText: '',
                  readOnly: true,
                  onTap: () {
                    // TODO: mở picker sách của nhóm
                  },
                ),

                const SizedBox(height: 18),
                const _Label(text: 'Số trang (tùy chọn)'),
                const SizedBox(height: 10),
                _TextFieldBox(
                  controller: _pageController,
                  hintText: 'VD: 150',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 18),
                _OutlineActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Chụp ảnh đoạn văn (OCR)',
                  onTap: () {
                    // TODO: gọi OCR (UI-only)
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
                        final len = value.text.length;
                        return Text(
                          '$len/5000',
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
                  maxLength: 5000,
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
                        label: 'Lưu ghi chú',
                        filled: true,
                        onTap: () {
                          // TODO: validate + gọi save của nhóm
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

/* ================== WIDGETS ================== */

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
              color: Color(0xFF101828),
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
          color: const Color(0xFF667085),
          splashRadius: 20,
        )
      ],
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
        color: Color(0xFF344054),
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
            color: Color(0xFF344054),
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD92D20),
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
  final bool readOnly;
  final VoidCallback? onTap;

  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF246BFF), width: 1.4),
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
        icon: Icon(icon, color: const Color(0xFF246BFF)),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF246BFF),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF9CC1FF), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      maxLines: 7,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '', // ẩn counter mặc định vì ta tự hiển thị 0/5000
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF246BFF), width: 1.4),
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
      borderRadius: BorderRadius.circular(14),
      onTap: () => onToggle(!enabled),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4CC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF4B400)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              enabled ? Icons.check_circle : Icons.circle_outlined,
              color: const Color(0xFFD97706),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tạo Flashcard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ghi chú này sẽ được đưa vào lịch ôn tập',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF667085),
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
    if (filled) {
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF246BFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF344054),
          side: const BorderSide(color: Color(0xFFD0D5DD)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
