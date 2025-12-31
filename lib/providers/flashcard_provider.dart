import 'package:flutter/material.dart';
import 'package:pht_04/models/flashcard_model.dart';

class FlashcardProvider extends ChangeNotifier {
  final List<Flashcard> _flashcards = <Flashcard>[];

  List<Flashcard> get flashcards => _flashcards;

  List<Flashcard> get dueFlashcards {
    final now = DateTime.now();
    return _flashcards
        .where(
          (c) =>
              c.nextReview.isBefore(now) || c.nextReview.isAtSameMomentAs(now),
        )
        .toList();
  }

  int get dueCount => dueFlashcards.length;

  int get streak => 7; // mocked

  int get reviewedThisWeek => 24; // mocked

  void loadMockData() {
    _flashcards.clear();
    _flashcards.addAll([
      Flashcard(
        id: '1',
        bookId: 'Thinking, Fast and Slow',
        frontText: 'Thinking, Fast and Slow',
        backText: 'Hệ thống 1 (tư duy nhanh) và hệ thống 2... ',
        nextReview: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Flashcard(
        id: '2',
        bookId: 'Sample Book',
        frontText: 'Quy tắc 1% là gì?',
        backText: 'Cải thiện 1% mỗi ngày...',
        nextReview: DateTime.now(),
      ),
      Flashcard(
        id: '3',
        bookId: 'Other',
        frontText: 'Not due',
        backText: 'Chưa đến hạn',
        nextReview: DateTime.now().add(const Duration(days: 3)),
      ),
    ]);
    notifyListeners();
  }
}
