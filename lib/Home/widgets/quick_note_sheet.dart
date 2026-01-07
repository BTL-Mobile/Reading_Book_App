import 'package:flutter/material.dart';

class QuickNoteSheet extends StatefulWidget {
  final int currentPage;

  const QuickNoteSheet({super.key, required this.currentPage});

  @override
  State<QuickNoteSheet> createState() => _QuickNoteSheetState();
}

class _QuickNoteSheetState extends State<QuickNoteSheet> {
  int _selectedTabIndex = 0; // 0: Viết ghi chú, 1: Danh sách ghi chú

  // Danh sách màu để chọn (Vàng, Xanh dương, Xanh lá, Hồng)
  final List<Color> _noteColors = [
    const Color(0xFFFFF59D), // Vàng
    const Color(0xFFE3F2FD), // Xanh dương nhạt
    const Color(0xFFE8F5E9), // Xanh lá nhạt
    const Color(0xFFFCE4EC), // Hồng nhạt
  ];

  int _selectedColorIndex = 0; // Mặc định chọn màu đầu tiên (Vàng)

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao bàn phím để đẩy nút lên khi gõ
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Chiếm 85% màn hình
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 1. HEADER (Màu xanh)
          _buildHeader(),

          // 2. TABS (Viết ghi chú | Ghi chú (0))
          _buildTabs(),

          // 3. NỘI DUNG (Thay đổi theo Tab)
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildWriteNoteForm(bottomPadding) // Form viết
                : _buildEmptyList(), // Danh sách trống
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2D68FF), // Màu xanh chủ đạo
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTabIndex == 0
                        ? "Ghi chú nhanh"
                        : "Danh sách ghi chú",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Trang ${widget.currentPage}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TABS ---
  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildTabItem("Viết ghi chú", 0, Icons.edit_note),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
          ), // Vách ngăn
          _buildTabItem("Ghi chú (0)", 1, Icons.sticky_note_2_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(color: Color(0xFF2D68FF), width: 2),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == 0)
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? const Color(0xFF2D68FF) : Colors.grey,
                ),
              if (index == 0) const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2D68FF) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: FORM VIẾT GHI CHÚ ---
  Widget _buildWriteNoteForm(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nội dung ghi chú",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Ô nhập liệu
          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const TextField(
              maxLines: null, // Cho phép xuống dòng thoải mái
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Nhập suy nghĩ, ý tưởng của bạn về đoạn văn...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Chọn màu ghi chú",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Chọn màu sắc
          Row(
            children: List.generate(_noteColors.length, (index) {
              bool isSelected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _noteColors[index],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Colors.orange,
                            width: 2,
                          ) // Viền cam khi chọn
                        : Border.all(color: Colors.transparent),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.bookmark,
                          size: 18,
                          color: Colors.orange,
                        )
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // Nút bấm Hủy / Lưu
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logic lưu ghi chú (sẽ làm sau)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã lưu ghi chú thành công!"),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Lưu ghi chú",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D68FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  // --- TAB 2: DANH SÁCH RỖNG ---
  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_off_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có ghi chú nào",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "Bắt đầu viết suy nghĩ của bạn về cuốn sách này",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
