import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import 'widgets/review_answer_buttons.dart';
import 'widgets/review_finish_dialog.dart';

class FlashcardPlayerScreen extends StatefulWidget {
  const FlashcardPlayerScreen({super.key});

  @override
  State<FlashcardPlayerScreen> createState() => _FlashcardPlayerScreenState();
}

class _FlashcardPlayerScreenState extends State<FlashcardPlayerScreen> {
  bool revealed = false;

  String _safe(dynamic card, String Function() getter, {String fallback = ''}) {
    try {
      return getter().toString();
    } catch (_) {
      return fallback;
    }
  }

  int _safeInt(dynamic p, int Function() getter, {int fallback = 0}) {
    try {
      return getter();
    } catch (_) {
      return fallback;
    }
  }

  List<dynamic> _safeList(dynamic p, List<dynamic> Function() getter) {
    try {
      return getter();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic p = context.watch<FlashcardProvider>();

    // cố gắng lấy deck “cần ôn” trước
    final deck = _safeList(p, () => p.reviewDeck).isNotEmpty
        ? _safeList(p, () => p.reviewDeck)
        : _safeList(p, () => p.dueFlashcards);

    final idx = _safeInt(p, () => p.currentIndex, fallback: 0);
    final total = deck.isEmpty ? 0 : deck.length;
    final current = (total == 0) ? null : deck[idx.clamp(0, total - 1)];

    final bookTitle = current == null
        ? ''
        : _safe(current, () => current.bookTitle, fallback: _safe(current, () => current.title, fallback: ''));

    final front = current == null
        ? ''
        : _safe(current, () => current.frontText, fallback: _safe(current, () => current.question, fallback: ''));

    final back = current == null
        ? ''
        : _safe(current, () => current.backText, fallback: _safe(current, () => current.answer, fallback: ''));

    final progress = total == 0 ? 0.0 : ((idx + 1) / total);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F6BFF), Color(0xFF1B3DCC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar + progress
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(idx + 1).clamp(1, total == 0 ? 1 : total)} / ${total == 0 ? 1 : total}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              if (bookTitle.isNotEmpty)
                Text(
                  bookTitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),
                ),

              const SizedBox(height: 18),

              // Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => setState(() => revealed = !revealed),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            revealed ? back : (front.isEmpty ? 'Nhấn để xem nội dung' : front),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: revealed ? 22 : (front.isEmpty ? 20 : 22),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // hint line
              Text(
                revealed ? 'Chọn mức độ ghi nhớ bên dưới' : 'Nhấn vào thẻ để xem nội dung',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              // Answer buttons
              ReviewAnswerButtons(
                enabled: current != null && revealed,
                onAnswer: (grade) async {
                  // grade: 0..3
                  setState(() => revealed = false);

                  try {
                    await p.answerCurrent(grade);
                  } catch (_) {
                    // fallback style
                    try {
                      await p.markAnswer(grade);
                    } catch (_) {}
                  }

                  // finish?
                  final newIdx = _safeInt(p, () => p.currentIndex, fallback: idx + 1);
                  if (total > 0 && newIdx >= total) {
                    if (!mounted) return;
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => ReviewFinishDialog(
                        finishedCount: total,
                        onClose: () {
                          Navigator.pop(context); // close dialog
                          Navigator.pop(context); // close player
                        },
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
