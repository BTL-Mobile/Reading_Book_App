import 'dart:io';
import 'package:flutter/material.dart';

class OcrResultBottomSheetKey extends StatefulWidget {
  const OcrResultBottomSheetKey({
    super.key,
    required this.initialText,
    this.imageProvider,
    required this.onRetake,
    required this.onUseText,
  });

  final String initialText;

  /// Dùng ảnh để preview: có thể truyền MemoryImage/FileImage/NetworkImage...
  final ImageProvider? imageProvider;

  final VoidCallback onRetake;

  /// Trả text khi bấm "Sử dụng văn bản này"
  final ValueChanged<String> onUseText;

  static Future<void> show(
    BuildContext context, {
    required String initialText,
    ImageProvider? imageProvider,
    required VoidCallback onRetake,
    required ValueChanged<String> onUseText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OcrResultBottomSheetKey(
        initialText: initialText,
        imageProvider: imageProvider,
        onRetake: onRetake,
        onUseText: onUseText,
      ),
    );
  }

  /// Helper nếu bạn đang có File ảnh:
  static ImageProvider fileImage(File file) => FileImage(file);

  @override
  State<OcrResultBottomSheetKey> createState() => _OcrResultBottomSheetKeyState();
}

class _OcrResultBottomSheetKeyState extends State<OcrResultBottomSheetKey> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _count => _controller.text.length;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 24, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chụp ảnh đoạn văn (OCR)',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF667085)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner success
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F7EF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB7E4C7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFF12B76A)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nhận diện thành công!\nBạn có thể chỉnh sửa văn bản bên dưới nếu cần',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF027A48),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Ảnh đã chụp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preview image box
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.imageProvider == null
                        ? const Center(
                            child: Icon(Icons.image, size: 44, color: Color(0xFF98A2B3)),
                          )
                        : Image(
                            image: widget.imageProvider!,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Văn bản đã nhận diện',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) => Text(
                          '${_count}/5000',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Text field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLength: 5000,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: 'Văn bản sẽ hiển thị ở đây...',
                        hintStyle: TextStyle(color: Color(0xFF98A2B3)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onRetake();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Chụp lại',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _controller.text.trim();
                        Navigator.pop(context);
                        widget.onUseText(text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sử dụng văn bản này',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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
