import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

import 'add_note_screen.dart';
import 'note_detail_screen.dart';
import 'trash_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _BookChip {
  final String key;
  final String title;
  final int count;

  const _BookChip({
    required this.key,
    required this.title,
    required this.count,
  });
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteService _noteService = NoteService();

  static const Map<String, String> kBookNameById = {
    'book_flutter_01': 'Atomic Habits',
    'book_flutter_02': 'Deep Work',
  };

  int selectedIndex = 0;
  List<_BookChip> _chips = const [];

  String _prettyBookTitle(Note n) {
    final t = n.bookTitle.trim();
    if (t.isNotEmpty && t != 'Sách') return t;
    return kBookNameById[n.bookId] ?? (n.bookId.isNotEmpty ? n.bookId : 'Sách');
  }

  void _rebuildChips(List<Note> notes) {
    final map = <String, _BookChip>{};

    for (final n in notes) {
      final key = n.bookId.isNotEmpty ? n.bookId : _prettyBookTitle(n);
      final title = _prettyBookTitle(n);

      final old = map[key];
      if (old == null) {
        map[key] = _BookChip(key: key, title: title, count: 1);
      } else {
        map[key] = _BookChip(
          key: old.key,
          title: old.title,
          count: old.count + 1,
        );
      }
    }

    final books = map.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    _chips = [
      _BookChip(key: '__all__', title: 'Tất cả', count: notes.length),
      ...books,
    ];

    if (selectedIndex >= _chips.length) selectedIndex = 0;
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_chips.isEmpty) return notes;
    if (selectedIndex == 0) return notes;

    final key = _chips[selectedIndex].key;
    return notes
        .where(
          (n) =>
      (n.bookId.isNotEmpty ? n.bookId : _prettyBookTitle(n)) == key,
    )
        .toList();
  }

  String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: StreamBuilder<List<Note>>(
          stream: _noteService.watchNotes(),
          builder: (context, snapshot) {
            final loading =
                snapshot.connectionState == ConnectionState.waiting;
            final allNotes = snapshot.data ?? [];

            _rebuildChips(allNotes);
            final notes = _filterNotes(allNotes);

            // ✅ FIX: đếm flashcard từ isConverted
            final flashcardsCount =
                allNotes.where((n) => n.isConverted).length;

            return CustomScrollView(
              slivers: [
                _buildTopBlueHeader(),

                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(18, 14, 18, 8),
                        child: _buildTitleRow(
                          allNotes.length,
                          flashcardsCount,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(18, 0, 18, 12),
                        child: _buildBookChips(),
                      ),
                    ),
                  ),
                ),

                if (loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (notes.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: _EmptyNotes(),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    sliver: SliverList.separated(
                      itemCount: notes.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final n = notes[index];

                        return _NoteCard(
                          bookTitle: _prettyBookTitle(n),
                          pageText: 'Trang ${n.pageNumber}',
                          dateText: _formatDate(n.updatedAt),
                          content: n.content,
                          isFlashcard: n.isConverted,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const NoteDetailScreen(),
                                settings:
                                RouteSettings(arguments: n),
                              ),
                            );
                          },
                          onDelete: () =>
                              _noteService.moveToTrash(n.id),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBlueHeader() {
    return SliverToBoxAdapter(
      child: Container(
        height: 150,
        width: double.infinity,
        color: const Color(0xFF1D63FF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Trạm Đọc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Trợ lý đọc sách chủ động & ghi nhớ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(int notesCount, int flashcardsCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ghi chú của tôi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$notesCount ghi chú · $flashcardsCount flashcards',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Thùng rác',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrashScreen()),
            );
          },
          icon: const Icon(Icons.delete_outline,
              color: Color(0xFF6B7280), size: 28),
        ),
        const SizedBox(width: 10),
        _BigCircleAddButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddNoteScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookChips() {
    if (_chips.isEmpty) return const SizedBox(height: 46);

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 2, right: 24),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final chip = _chips[i];
          final selected = i == selectedIndex;

          final label =
          i == 0 ? 'Tất cả (${chip.count})' : chip.title;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => selectedIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1D63FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1D63FF)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF374151),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BigCircleAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BigCircleAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1D63FF),
      shape: const CircleBorder(),
      elevation: 8,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 62,
          height: 62,
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String bookTitle;
  final String pageText;
  final String dateText;
  final String content;
  final bool isFlashcard;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _NoteCard({
    required this.bookTitle,
    required this.pageText,
    required this.dateText,
    required this.content,
    required this.isFlashcard,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: const Color(0xFFF5B700), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$bookTitle · $pageText',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isFlashcard)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: const Color(0xFFFDE68A)),
                    ),
                    child: const Text(
                      'Flashcard',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.35,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.description_outlined,
              size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 12),
          Text(
            'Chưa có ghi chú',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Nhấn nút + để tạo ghi chú mới',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
