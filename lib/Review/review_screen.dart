import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../Home/settings_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu
    final provider = context.watch<FlashcardProvider>();
    final now = DateTime.now();

    // Lấy tối đa 5 thẻ chưa đến hạn để hiện ở list dưới
    final upcomingCards = provider.flashcards
        .where((card) => card.nextReview.isAfter(now))
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      // 👇 SỬA Ở ĐÂY: Dùng SingleChildScrollView bọc toàn bộ Body
      body: SingleChildScrollView(
        // Không dùng padding ở đây để Header tràn viền
        child: Column(
          children: [
            // 1. Header nằm trong vùng cuộn -> Sẽ trôi đi khi vuốt
            _buildHeader(context),

            // 2. Phần nội dung còn lại
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hệ thống ôn tập ngắt quãng giúp bạn ghi nhớ lâu dài",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 3. Stats Row
                  Row(
                    children: [
                      _buildSquareStatCard(
                        "${provider.dueCount}",
                        "Cần ôn\nhôm nay",
                        const Color(0xFF2D68FF),
                      ),
                      const SizedBox(width: 12),
                      _buildSquareStatCard(
                        "${provider.streak}",
                        "Chuỗi ngày",
                        const Color(0xFF00C853),
                      ),
                      const SizedBox(width: 12),
                      _buildSquareStatCard(
                        "${provider.reviewedThisWeek}",
                        "Đã ôn tuần\nnày",
                        const Color(0xFFAA00FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Main Action Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFCC80),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 56,
                          color: Color(0xFFEF6C00),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.dueCount > 0
                              ? "Bạn có ${provider.dueCount} flashcard cần ôn tập"
                              : "Bạn đã hoàn thành bài ôn tập!",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (provider.dueCount > 0)
                          const Text(
                            "Chỉ mất khoảng 4 phút",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: provider.dueCount > 0
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Bắt đầu học..."),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Bắt đầu ôn tập",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF6C00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 5. Lịch ôn tập sắp tới
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF333333),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Lịch ôn tập sắp tới",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (upcomingCards.isEmpty)
                    _buildEmptyState()
                  else
                    ...upcomingCards.map((card) {
                      final daysLeft = card.nextReview
                          .difference(DateTime.now())
                          .inDays;
                      final displayTime = daysLeft <= 0
                          ? "Mai"
                          : "Sau\n${daysLeft}d";

                      return _buildUpcomingCard(
                        displayTime,
                        card.bookId.isNotEmpty
                            ? card.bookId
                            : "Thinking, Fast and Slow",
                        card.frontText.isNotEmpty
                            ? card.frontText
                            : "Hệ thống 1...",
                      );
                    }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER (Giữ nguyên) ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blueAccent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .center, // Đổi lại thành spaceBetween để nút setting sang phải
        children: [
          const Column(
            // Thêm const cho tối ưu
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn trái cho text đẹp hơn
            children: [
              Text(
                "Trạm Đọc",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Trợ lý đọc sách chủ động & ghi nhớ",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET CON KHÁC (Giữ nguyên) ---
  Widget _buildSquareStatCard(String number, String label, Color color) {
    return Expanded(
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(String timeBadge, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              timeBadge,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_available, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            "Bạn không có lịch ôn tập nào sắp tới",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
