import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import 'flashcard_library_screen.dart';
import 'flashcard_player_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  int _safeInt(dynamic p, int Function() getter, {int fallback = 0}) {
    try {
      return getter();
    } catch (_) {
      return fallback;
    }
  }

  List<dynamic> _safeList(dynamic p, List<dynamic> Function() getter) {
    try {
      final v = getter();
      return v;
    } catch (_) {
      return const [];
    }
  }

  String _safeString(dynamic card, String Function() getter, {String fallback = ''}) {
    try {
      final v = getter();
      return v.toString();
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic p = context.watch<FlashcardProvider>();

    final dueToday = _safeInt(p, () => p.dueToday);
    final streak = _safeInt(p, () => p.streakDays);
    final reviewedThisWeek = _safeInt(p, () => p.reviewedThisWeek);

    final upcoming = _safeList(p, () => p.upcomingReviews);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header blue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF1E67FF),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: const [
                  Text(
                    'Trạm Đọc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Trợ lý đọc sách chủ động & ghi nhớ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ôn tập ghi nhớ',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Hệ thống ôn tập ngắt quãng giúp bạn ghi nhớ lâu dài',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FlashcardLibraryScreen()),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.bar_chart_rounded, color: Color(0xFF1E67FF)),
                              SizedBox(width: 6),
                              Text(
                                'Thư viện',
                                style: TextStyle(
                                  color: Color(0xFF1E67FF),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3 stat cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            color: const Color(0xFF1E67FF),
                            value: '$dueToday',
                            label: 'Cần ôn\nhôm nay',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            color: const Color(0xFF00B341),
                            value: '$streak',
                            label: 'Chuỗi ngày',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            color: const Color(0xFF9B4DFF),
                            value: '$reviewedThisWeek',
                            label: 'Đã ôn tuần\nnày',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Big start card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF4B400), width: 2),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          const Icon(Icons.psychology_rounded, size: 56, color: Color(0xFFE07A00)),
                          const SizedBox(height: 12),
                          Text(
                            'Bạn có $dueToday flashcard cần ôn tập',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chỉ mất khoảng ${(dueToday * 2).clamp(2, 30)} phút',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: dueToday <= 0
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FlashcardPlayerScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE07A00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: const Text(
                                'Bắt đầu ôn tập',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Upcoming schedule card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_month_rounded, color: Color(0xFF374151)),
                              SizedBox(width: 10),
                              Text(
                                'Lịch ôn tập sắp tới',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (upcoming.isEmpty)
                            const Text(
                              'Chưa có lịch ôn tập sắp tới.',
                              style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                            )
                          else
                            _UpcomingRow(
                              badgeText: _safeString(upcoming.first, () => upcoming.first.badgeText, fallback: 'Sau\n3d'),
                              title: _safeString(upcoming.first, () => upcoming.first.title, fallback: 'Thinking, Fast and Slow'),
                              subtitle: _safeString(upcoming.first, () => upcoming.first.subtitle, fallback: 'Hệ thống 1 (tư duy nhanh)...'),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const _UpcomingRow({
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0ECFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              badgeText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E67FF),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
