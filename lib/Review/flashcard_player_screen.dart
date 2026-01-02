import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_model.dart';

class FlashcardPlayerScreen extends StatefulWidget {
  final List<Flashcard> dueCards;

  const FlashcardPlayerScreen({super.key, required this.dueCards});

  @override
  State<FlashcardPlayerScreen> createState() => _FlashcardPlayerScreenState();
}

class _FlashcardPlayerScreenState extends State<FlashcardPlayerScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false; // Trạng thái lật thẻ

  @override
  Widget build(BuildContext context) {
    // 1. Nếu đã học hết thẻ -> Hiện màn hình Hoàn thành
    if (_currentIndex >= widget.dueCards.length) {
      return _buildCompletionScreen();
    }

    final card = widget.dueCards[_currentIndex];
    final progress = (_currentIndex + 1) / widget.dueCards.length;

    return Scaffold(
      // Nền Gradient xanh dương
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2962FF), Color(0xFF536DFE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${_currentIndex + 1} / ${widget.dueCards.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- DISPLAY CARD ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isFlipped = !_isFlipped;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  height: 420,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.bookId.isNotEmpty ? card.bookId : "Flashcard",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Text(
                        _isFlipped ? card.backText : card.frontText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      if (!_isFlipped)
                        const Text(
                          "Chạm vào thẻ để xem đáp án",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- KHU VỰC NÚT ĐÁNH GIÁ (Đã sửa lại theo yêu cầu) ---
              if (_isFlipped)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bạn nhớ nội dung này như thế nào?",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      // 👇 SỬA Ở ĐÂY: Quay về 1 hàng ngang (Row) 4 nút 👇
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // Căn đều các nút
                        children: [
                          _buildRatingButton(
                            "Quên rồi",
                            Colors.red.shade50,
                            Colors.red,
                            1,
                          ),
                          _buildRatingButton(
                            "Khó nhớ",
                            Colors.orange.shade50,
                            Colors.orange,
                            2,
                          ),
                          _buildRatingButton(
                            "Nhớ được",
                            Colors.green.shade50,
                            Colors.green,
                            3,
                          ),
                          _buildRatingButton(
                            "Dễ ợt",
                            Colors.blue.shade50,
                            Colors.blue,
                            4,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 130), // Giữ chỗ khi chưa lật
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget nút đánh giá (Đã sửa style giống ảnh mẫu) ---
  Widget _buildRatingButton(String label, Color bg, Color color, int rating) {
    return InkWell(
      onTap: () => _handleReview(rating),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // Đặt kích thước cố định để tạo hình vuông
        width: 80,
        height: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg, // Màu nền nhạt
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ), // Viền màu
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Wait", // Chữ Wait nhỏ bên trên
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              label, // Nhãn chính (Quên rồi, v.v.)
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic xử lý ---
  void _handleReview(int rating) async {
    final provider = context.read<FlashcardProvider>();
    final currentCard = widget.dueCards[_currentIndex];
    await provider.processReview(currentCard, rating);
    if (mounted) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  // --- Màn hình Hoàn thành ---
  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Color(0xFF00C853),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Hoàn thành!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Bạn đã ôn tập xong ${widget.dueCards.length} flashcards hôm nay.\nTuyệt vời! 🎉",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Đóng",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
