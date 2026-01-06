import 'package:flutter/material.dart';
import 'ocr_result_screen.dart';

class OcrModal extends StatelessWidget {
  const OcrModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chụp ảnh đoạn văn (OCR)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Nút Chụp ảnh
                  _buildBigButton(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xFF155DFC),
                    bgColor: const Color(0xFFEFF6FF), // Xanh rất nhạt
                    title: 'Chụp ảnh',
                    subtitle: 'Mở camera để chụp đoạn văn',
                    borderColor: const Color(0xFFBFDBFE),
                    onTap: () => _goToResult(context),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('hoặc', style: TextStyle(color: Colors.grey)),
                  ),

                  // Nút Tải ảnh
                  _buildBigButton(
                    icon: Icons.upload_file,
                    color: const Color(0xFF4B5563),
                    bgColor: Colors.white,
                    title: 'Tải ảnh lên',
                    subtitle: 'Chọn ảnh từ thư viện',
                    borderColor: const Color(0xFFE5E7EB),
                    onTap: () => _goToResult(context),
                  ),

                  const Spacer(),

                  // Hộp Mẹo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Column( // Đã thêm const tại dòng 75
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFD97706)),
                            SizedBox(width: 8),
                            Text('Mẹo để OCR chính xác hơn:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• Chụp trong điều kiện ánh sáng tốt', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                        Text('• Giữ máy thẳng và ổn định', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút Hủy
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _goToResult(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OcrResultScreen())
    );

    if (!context.mounted) return;

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  Widget _buildBigButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required Color borderColor,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}