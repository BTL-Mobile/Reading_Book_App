import 'package:flutter/material.dart';

class NotesScreenKey extends StatefulWidget {
  const NotesScreenKey({super.key});

  @override
  State<NotesScreenKey> createState() => _NotesScreenKeyState();
}

class _NotesScreenKeyState extends State<NotesScreenKey> {
  int selectedChip = 0;

  // TODO: thay bằng danh sách sách thật của nhóm
  final List<String> chips = ['Tất cả (3)', 'Atomic Habits', 'Thinking, F'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _HeaderBlue(
            title: 'Trạm Đọc',
            subtitle: 'Trợ lý đọc sách chủ động & ghi nhớ',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(
                    title: 'Ghi chú của tôi',
                    subtitle: '3 ghi chú · 2 flashcards',
                    onTrashTap: () {
                      // TODO: push Trash screen của bạn
                      // Navigator.push(...);
                    },
                    onAddTap: () {
                      // TODO: mở màn thêm note
                    },
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final bool isSelected = selectedChip == index;
                        return _ChipPill(
                          label: chips[index],
                          selected: isSelected,
                          showBookIcon: index != 0,
                          onTap: () => setState(() => selectedChip = index),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _NoteCard(
                    book: 'Atomic Habits',
                    page: 'Trang 15',
                    date: '16/11/2024',
                    content:
                        'Thói quen tốt là nền tảng cho sự thành công. Quy tắc 1%: Cải thiện mỗi ngày 1% sẽ tạo ra sự khác biệt lớn sau 1 năm.',
                    onDeleteTap: () {},
                  ),
                  const SizedBox(height: 14),
                  _NoteCard(
                    book: 'Atomic Habits',
                    page: 'Trang 53',
                    date: '18/11/2024',
                    content:
                        '4 quy luật của việc thay đổi hành vi:\n1. Làm cho nó rõ ràng\n2. Làm cho nó hấp dẫn\n3. Làm cho nó dễ dàng\n4. Làm cho nó thỏa mãn',
                    onDeleteTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating + giống ảnh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: thêm note
        },
        backgroundColor: const Color(0xFF246BFF),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class _HeaderBlue extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderBlue({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF246BFF),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xDFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTrashTap;
  final VoidCallback onAddTap;

  const _TitleRow({
    required this.title,
    required this.subtitle,
    required this.onTrashTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: onTrashTap,
          icon: const Icon(Icons.delete_outline_rounded),
          color: const Color(0xFF667085),
          tooltip: 'Thùng rác',
        ),
      ],
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showBookIcon;
  final VoidCallback onTap;

  const _ChipPill({
    required this.label,
    required this.selected,
    required this.showBookIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF246BFF) : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF344054);
    final border = selected ? const Color(0xFF246BFF) : const Color(0xFFD0D5DD);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBookIcon) ...[
              Icon(Icons.menu_book_rounded, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String book;
  final String page;
  final String date;
  final String content;
  final VoidCallback onDeleteTap;

  const _NoteCard({
    required this.book,
    required this.page,
    required this.date,
    required this.content,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4B400), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 20, color: Color(0xFF667085)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$book  ·  $page',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 20,
              height: 1.35,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: onDeleteTap,
              icon: const Icon(Icons.delete_outline_rounded),
              color: const Color(0xFF98A2B3),
              tooltip: 'Xóa',
            ),
          ),
        ],
      ),
    );
  }
}
