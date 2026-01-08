import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import 'widgets/review_finish_dialog.dart';

class FlashcardPlayerScreen extends StatefulWidget {
  const FlashcardPlayerScreen({super.key});

  @override
  State<FlashcardPlayerScreen> createState() => _FlashcardPlayerScreenState();
}

class _FlashcardPlayerScreenState extends State<FlashcardPlayerScreen> {
  bool revealed = false;

  String _safe(dynamic card, Object? Function() getter, {String fallback = ''}) {
    try {
      final v = getter();
      if (v == null) return fallback;
      return v.toString();
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

  Future<void> _answer(dynamic p, int grade, int total, int idx) async {
    setState(() => revealed = false);

    try {
      await p.answerCurrent(grade);
    } catch (_) {
      try {
        await p.markAnswer(grade);
      } catch (_) {}
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final dynamic p = context.watch<FlashcardProvider>();

    final deckRaw = _safeList(p, () => p.reviewDeck);
    final dueRaw = _safeList(p, () => p.dueFlashcards);
    final deck = deckRaw.isNotEmpty ? deckRaw : dueRaw;

    final idx = _safeInt(p, () => p.currentIndex, fallback: 0);
    final total = deck.isEmpty ? 0 : deck.length;
    final current = (total == 0) ? null : deck[idx.clamp(0, total - 1)];

    final bookTitle = current == null
        ? ''
        : _safe(
      current,
          () => current.bookTitle,
      fallback: _safe(current, () => current.title, fallback: ''),
    );

    final front = current == null
        ? ''
        : _safe(
      current,
          () => current.frontText,
      fallback: _safe(current, () => current.question, fallback: ''),
    );

    final back = current == null
        ? ''
        : _safe(
      current,
          () => current.backText,
      fallback: _safe(current, () => current.answer, fallback: ''),
    );

    final progress = total == 0 ? 0.0 : ((idx + 1) / total);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (đặt dưới, không ảnh hưởng hit test)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2F6BFF), Color(0xFF1B3DCC)],
                ),
              ),
            ),
          ),

          SafeArea(
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
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

                const SizedBox(height: 10),

                if (bookTitle.isNotEmpty)
                  Text(
                    bookTitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),
                  ),

                const SizedBox(height: 12),

                // Card (không bắt buộc phải tap)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            revealed
                                ? (back.isEmpty ? 'Chưa có đáp án' : back)
                                : (front.isEmpty ? 'Nhấn nút bên dưới để xem' : front),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Nút reveal/ẩn đáp án (thay vì bắt buộc tap card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: current == null ? null : () => setState(() => revealed = !revealed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        revealed ? 'Ẩn đáp án' : 'Hiện đáp án',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  revealed ? 'Chọn mức độ ghi nhớ bên dưới' : 'Bấm “Hiện đáp án” để bắt đầu',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 12),

                // 4 nút trả lời
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _AnsBtn(
                              enabled: current != null && revealed,
                              text: '😰  Quên rồi\nÔn lại sau 10 phút',
                              onTap: () => _answer(p, 0, total, idx),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnsBtn(
                              enabled: current != null && revealed,
                              text: '🤔  Khó nhớ\nÔn lại sau 1 ngày',
                              onTap: () => _answer(p, 1, total, idx),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _AnsBtn(
                              enabled: current != null && revealed,
                              text: '👍  Nhớ được\nÔn lại sau 3 ngày',
                              onTap: () => _answer(p, 2, total, idx),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnsBtn(
                              enabled: current != null && revealed,
                              text: '😎  Dễ ợt\nÔn lại sau 1 tuần',
                              onTap: () => _answer(p, 3, total, idx),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnsBtn extends StatelessWidget {
  final bool enabled;
  final String text;
  final VoidCallback onTap;

  const _AnsBtn({
    required this.enabled,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        disabledBackgroundColor: Colors.white.withOpacity(0.25),
        disabledForegroundColor: Colors.white.withOpacity(0.7),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
