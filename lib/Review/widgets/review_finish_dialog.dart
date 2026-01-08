import 'package:flutter/material.dart';

class ReviewFinishDialog extends StatelessWidget {
  final int finishedCount;
  final VoidCallback onClose;

  const ReviewFinishDialog({
    super.key,
    required this.finishedCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 72, color: Color(0xFF00B341)),
            const SizedBox(height: 14),
            const Text('Hoàn thành!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(
              'Bạn đã ôn tập xong $finishedCount flashcards\nhôm nay. Tuyệt vời! 🎉',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E67FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Đóng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
