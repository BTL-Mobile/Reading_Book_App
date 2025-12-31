// File: lib/features/library/widgets/table_of_contents_drawer.dart

import 'package:flutter/material.dart';

class TableOfContentsDrawer extends StatelessWidget {
  // Nhận vào chỉ số chương đang đọc để highlight
  final int currentChapterIndex;

  // Hàm callback khi người dùng chọn chương
  final Function(Map<String, dynamic> chapter) onChapterTap;

  const TableOfContentsDrawer({
    super.key,
    required this.currentChapterIndex,
    required this.onChapterTap,
  });

  // Dữ liệu giả lập (Sau này có thể truyền từ bên ngoài vào hoặc lấy từ API)
  final List<Map<String, dynamic>> _chapters = const [
    {"title": "Sức mạnh của thói quen nhỏ", "subtitle": "Chương 1", "page": 1},
    {
      "title": "Cách thói quen định hình bản sắc",
      "subtitle": "Chương 2",
      "page": 15,
    },
    {
      "title": "Bốn quy luật thay đổi hành vi",
      "subtitle": "Chương 3",
      "page": 28,
    },
    {"title": "Làm cho nó rõ ràng", "subtitle": "Chương 4", "page": 42},
    {"title": "Làm cho nó hấp dẫn", "subtitle": "Chương 5", "page": 58},
    {"title": "Làm cho nó dễ dàng", "subtitle": "Chương 6", "page": 77},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // Header
          Container(
            height: 100,
            padding: const EdgeInsets.only(top: 40, left: 20, right: 10),
            color: const Color(0xFF2D68FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Mục lục",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _chapters.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final bool isSelected = index == currentChapterIndex;

                return InkWell(
                  onTap: () {
                    Navigator.pop(context); // Đóng drawer
                    onChapterTap(chapter); // Gửi dữ liệu về màn hình chính
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSelected)
                          Container(
                            width: 4,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D68FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        else
                          const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    chapter['subtitle'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    "Trang ${chapter['page']}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chapter['title'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
