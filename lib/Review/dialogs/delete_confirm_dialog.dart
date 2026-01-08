import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xác nhận xóa',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            const Text(
              'Bạn có chắc chắn muốn xóa thẻ này không?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xóa', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
