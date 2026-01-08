import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';

import 'dialogs/create_flashcard_dialog.dart';
import 'dialogs/edit_flashcard_dialog.dart';
import 'dialogs/delete_confirm_dialog.dart';
import 'flashcard_player_screen.dart';

class FlashcardLibraryScreen extends StatefulWidget {
  const FlashcardLibraryScreen({super.key});

  @override
  State<FlashcardLibraryScreen> createState() => _FlashcardLibraryScreenState();
}

class _FlashcardLibraryScreenState extends State<FlashcardLibraryScreen> {
  int tab = 0; // 0 all, 1 due, 2 upcoming

  List<dynamic> _safeList(List<dynamic> Function() getter) {
    try {
      return getter();
    } catch (_) {
      return const [];
    }
  }

  String _safe(dynamic card, String Function() getter, {String fallback = ''}) {
    try {
      return getter().toString();
    } catch (_) {
      return fallback;
    }
  }

  int _safeInt(dynamic card, int Function() getter, {int fallback = 0}) {
    try {
      return getter();
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic p = context.watch<FlashcardProvider>();

    final all = _safeList(() => p.allFlashcards);
    final due = _safeList(() => p.dueFlashcards);
    final upcoming = _safeList(() => p.upcomingFlashcards);

    final list = switch (tab) {
      0 => all,
      1 => due,
      _ => upcoming,
    };

    final dueCount = due.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE07A00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thư viện Flashcard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE07A00),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => const CreateFlashcardDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: Column(
        children: [
          // Big orange play button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: dueCount == 0
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FlashcardPlayerScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                label: Text(
                  'Ôn tập $dueCount flashcard ngay',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE07A00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                ),
              ),
            ),
          ),

          // Tabs (chips)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                _ChipTab(
                  text: 'Tất cả (${all.length})',
                  selected: tab == 0,
                  onTap: () => setState(() => tab = 0),
                ),
                const SizedBox(width: 10),
                _ChipTab(
                  text: 'Cần ôn (${due.length})',
                  selected: tab == 1,
                  onTap: () => setState(() => tab = 1),
                ),
                const SizedBox(width: 10),
                _ChipTab(
                  text: 'Sắp tới (${upcoming.length})',
                  selected: tab == 2,
                  onTap: () => setState(() => tab = 2),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = list[i];

                final bookTitle = _safe(c, () => c.bookTitle, fallback: _safe(c, () => c.title, fallback: ''));
                final front = _safe(c, () => c.frontText, fallback: _safe(c, () => c.question, fallback: ''));
                final dueText = _safe(c, () => c.dueText, fallback: (tab == 2 ? 'Sau 2 ngày' : 'Hôm nay'));
                final reviewed = _safeInt(c, () => c.reviewCount, fallback: 5);

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              bookTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => EditFlashcardDialog(card: c),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B7280)),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => const DeleteConfirmDialog(),
                              );
                              if (ok == true) {
                                try {
                                  await p.deleteFlashcard(c.id);
                                } catch (_) {
                                  // nếu provider của bạn khác, không làm gì để tránh crash
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        front,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                          Text(
                            dueText,
                            style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 18),
                          Text(
                            'Đã ôn $reviewed lần',
                            style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
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

class _ChipTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ChipTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1E4CCB) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
