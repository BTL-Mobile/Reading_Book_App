import 'package:flutter/material.dart';

class ConfirmDeleteNoteBottomSheetKey extends StatelessWidget {
  const ConfirmDeleteNoteBottomSheetKey({super.key});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirmDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: false,
      builder: (_) => ConfirmDeleteNoteBottomSheetKey(
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  final VoidCallback onConfirmDelete;

  const ConfirmDeleteNoteBottomSheetKey({
    super.key,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon cảnh báo
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE4E4),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Xác nhận xóa',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Bạn có chắc chắn muốn xóa ghi chú này vĩnh viễn?\n'
            'Hành động này không thể hoàn tác.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475467),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirmDelete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
