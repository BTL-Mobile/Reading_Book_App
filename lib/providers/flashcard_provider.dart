import 'dart:async';
import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../services/flashcard_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardService _service = FlashcardService();

  List<Flashcard> _flashcards = [];
  StreamSubscription? _subscription; // Để quản lý lắng nghe stream

  List<Flashcard> get flashcards => _flashcards;

  // Lấy danh sách cần ôn (Due <= Now)
  List<Flashcard> get dueFlashcards {
    final now = DateTime.now();
    return _flashcards
        .where(
          (card) =>
              card.nextReview.isBefore(now) ||
              card.nextReview.isAtSameMomentAs(now),
        )
        .toList();
  }

  int get dueCount => dueFlashcards.length;

  // Tính chuỗi ngày streak (Logic đơn giản: đếm số thẻ có streak > 0)
  int get streak => _flashcards.where((c) => c.streak > 0).length;

  // Tính số thẻ đã ôn tuần này (Tạm thời fix cứng hoặc cần logic phức tạp hơn ở backend)
  int get reviewedThisWeek => _flashcards.where((c) => c.interval > 0).length;

  // --- 1. KHỞI TẠO: Lắng nghe dữ liệu thật từ Firestore ---
  void initData() {
    _subscription = _service.getFlashcardsStream().listen((data) {
      _flashcards = data;
      notifyListeners(); // Giao diện tự cập nhật khi DB thay đổi
    });
  }

  // --- 2. LOGIC ÔN TẬP (SM-2 Algorithm) ---
  // rating: 1 (Quên), 2 (Khó nhớ), 3 (Nhớ được), 4 (Dễ)
  Future<void> processReview(Flashcard card, int rating) async {
    int newInterval;
    double newEaseFactor;
    int newStreak;

    if (rating >= 3) {
      // TRƯỜNG HỢP NHỚ (Correct)
      if (card.streak == 0) {
        newInterval = 1;
      } else if (card.streak == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easinessFactor).round();
      }

      newStreak = card.streak + 1;
      // Công thức chỉnh độ khó
      newEaseFactor =
          card.easinessFactor +
          (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3; // Giới hạn thấp nhất
    } else {
      // TRƯỜNG HỢP QUÊN (Incorrect)
      newInterval = 1; // Reset về 1 ngày (hoặc 0 để ôn lại ngay lập tức)
      newStreak = 0;
      newEaseFactor = card.easinessFactor; // Giữ nguyên độ khó
    }

    // Tính ngày review tiếp theo
    DateTime newNextReview = DateTime.now().add(Duration(days: newInterval));

    // Gọi Service lưu xuống Database
    await _service.updateReviewStatus(
      card.id,
      newNextReview,
      newInterval,
      newEaseFactor,
      newStreak,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hủy lắng nghe khi thoát app
    super.dispose();
  }
}
