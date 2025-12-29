import 'package:flutter/material.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Thùng rác", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF155CFB), Color(0xFF432DD7)]),
          ),
        ),
        titleSpacing: 0,
        toolbarHeight: 60,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: const Row(
              children: [
                BackButton(color: Colors.black),
                Expanded(child: Center(child: Text("Thùng rác", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row( // Thêm const tại dòng 32, 33
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Các ghi chú trong thùng rác sẽ tự động bị xóa vĩnh viễn sau 30 ngày",
                          style: TextStyle(color: Color(0xFF92400E), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                Icon(Icons.delete_outline, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16), // Thêm const tại dòng 53
                Text("Thùng rác trống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text("Các ghi chú đã xóa sẽ xuất hiện ở đây", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}