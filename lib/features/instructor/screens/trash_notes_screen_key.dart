import 'package:flutter/material.dart';

class TrashNotesScreenKey extends StatelessWidget {
  const TrashNotesScreenKey({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng list notes bị xóa từ provider/service của nhóm
    final bool isEmpty = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thùng rác'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _WarningBanner(
              text: 'Các ghi chú trong thùng rác sẽ tự động bị xóa vĩnh viễn sau 30 ngày',
            ),
            const SizedBox(height: 22),

            Expanded(
              child: isEmpty
                  ? const _EmptyTrash()
                  : ListView.separated(
                      itemCount: 10, // TODO: notesDeleted.length
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _TrashNoteTile(
                          title: 'Ghi chú #$index',
                          subtitle: 'Đã xóa gần đây',
                          onRestore: () {},
                          onDeleteForever: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;
  const _WarningBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD18A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB26A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7A4B00),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            size: 72,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 12),
          Text(
            'Thùng rác trống',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Các ghi chú đã xóa sẽ xuất hiện ở đây',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF98A2B3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrashNoteTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  const _TrashNoteTile({
    required this.title,
    required this.subtitle,
    required this.onRestore,
    required this.onDeleteForever,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Color(0xFF667085)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Khôi phục',
            icon: const Icon(Icons.restore_rounded),
            onPressed: onRestore,
          ),
          IconButton(
            tooltip: 'Xóa vĩnh viễn',
            icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD92D20)),
            onPressed: onDeleteForever,
          ),
        ],
      ),
    );
  }
}
