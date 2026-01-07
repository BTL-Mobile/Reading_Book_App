import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_model.dart';
import '../services/flashcard_service.dart';
import 'flashcard_player_screen.dart';

class FlashcardLibraryScreen extends StatefulWidget {
  const FlashcardLibraryScreen({super.key});

  @override
  State<FlashcardLibraryScreen> createState() => _FlashcardLibraryScreenState();
}

class _FlashcardLibraryScreenState extends State<FlashcardLibraryScreen> {
  int _filterIndex = 0; // 0: Tất cả, 1: Cần ôn, 2: Sắp tới

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final allCards = provider.flashcards;
    final now = DateTime.now();

    // Logic lọc thẻ
    List<Flashcard> displayedCards = [];
    if (_filterIndex == 0) {
      displayedCards = allCards;
    } else if (_filterIndex == 1) {
      displayedCards = allCards
          .where(
            (c) =>
                c.nextReview.isBefore(now) ||
                c.nextReview.isAtSameMomentAs(now),
          )
          .toList();
    } else {
      displayedCards = allCards
          .where((c) => c.nextReview.isAfter(now))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6D00),
        title: const Text(
          "Thư viện Flashcard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6D00),
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // 👇 SỬA ĐỔI QUAN TRỌNG Ở ĐÂY 👇
      // Thay vì Column chia cắt, dùng ListView chứa tất cả mọi thứ
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ), // Padding tổng thể (Bottom 100 để tránh nút FAB che)
        children: [
          // 1. NÚT ÔN TẬP (Sẽ cuộn cùng danh sách)
          if (displayedCards.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FlashcardPlayerScreen(dueCards: displayedCards),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: Text(
                  _filterIndex == 1
                      ? "Ôn tập ${displayedCards.length} thẻ cần ôn ngay"
                      : "Học thử ${displayedCards.length} thẻ danh sách này",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  shadowColor: Colors.orange.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 16), // Khoảng cách dưới nút
          ],

          // 2. BỘ LỌC (Chips) (Sẽ cuộn cùng danh sách)
          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal, // Cho phép lướt ngang nếu nhiều nút quá
            child: Row(
              children: [
                _buildFilterChip("Tất cả (${allCards.length})", 0),
                const SizedBox(width: 8),
                _buildFilterChip("Cần ôn (${provider.dueCount})", 1),
                const SizedBox(width: 8),
                _buildFilterChip(
                  "Sắp tới (${allCards.length - provider.dueCount})",
                  2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // Khoảng cách giữa bộ lọc và danh sách
          // 3. DANH SÁCH THẺ (Hoặc thông báo trống)
          if (displayedCards.isEmpty)
            Container(
              height: 300, // Chiều cao tạm để căn giữa nội dung trống
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    "Không có thẻ nào",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          else
            // Dùng toán tử spread (...) để bung danh sách thẻ ra thành các phần tử con của ListView cha
            ...displayedCards.map((card) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ), // Khoảng cách giữa các thẻ
                child: _buildCardItem(context, card),
              );
            }).toList(),
        ],
      ),
    );
  }

  // --- Widget nút lọc ---
  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D68FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- Widget hiển thị Card ---
  Widget _buildCardItem(BuildContext context, Flashcard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc mềm mại hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.book,
                      size: 16,
                      color: Colors.grey,
                    ), // Icon sách đậm
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.bookId.isNotEmpty ? card.bookId : "Chưa phân loại",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Sửa",
                    onPressed: () => _showEditDialog(context, card),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Xóa",
                    onPressed: () => _confirmDelete(context, card.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.frontText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.backText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoBadge(
                Icons.calendar_month,
                _formatDate(card.nextReview),
                card.nextReview.isBefore(DateTime.now())
                    ? Colors.orange
                    : Colors.grey,
              ),
              const SizedBox(width: 16),
              _buildInfoBadge(
                Icons.refresh,
                "Streak: ${card.streak}",
                Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (date.isBefore(now)) return "Hôm nay";
    if (difference == 0) return "Ngày mai";
    if (difference < 7) return "Sau $difference ngày";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // --- DIALOGS (Giữ nguyên phần Textbox như bạn yêu cầu) ---
  void _showAddDialog(BuildContext context) {
    final bookCtrl = TextEditingController(text: "Sách chung");
    final frontCtrl = TextEditingController();
    final backCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo thẻ mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên sách / Chủ đề",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frontCtrl,
                decoration: const InputDecoration(
                  labelText: "Mặt trước (Câu hỏi)",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backCtrl,
                decoration: const InputDecoration(
                  labelText: "Mặt sau (Đáp án)",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontCtrl.text.isEmpty || backCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await FlashcardService().addCard(
                bookCtrl.text.isEmpty ? "Chưa phân loại" : bookCtrl.text,
                frontCtrl.text,
                backCtrl.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm thẻ mới thành công!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D00),
            ),
            child: const Text("Tạo thẻ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Flashcard card) {
    final frontCtrl = TextEditingController(text: card.frontText);
    final backCtrl = TextEditingController(text: card.backText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa thẻ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: frontCtrl,
                decoration: const InputDecoration(
                  labelText: "Mặt trước",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backCtrl,
                decoration: const InputDecoration(
                  labelText: "Mặt sau",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FlashcardService().updateCardContent(
                card.id,
                frontCtrl.text,
                backCtrl.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa thẻ này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FlashcardService().deleteCard(cardId);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
