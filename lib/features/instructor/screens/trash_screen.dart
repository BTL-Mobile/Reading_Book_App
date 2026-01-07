import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _deleteForever(BuildContext context, NoteService service, Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa vĩnh viễn?'),
        content: const Text('Ghi chú sẽ bị xóa vĩnh viễn và không thể khôi phục.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await service.deletePermanently(note.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa ghi chú vĩnh viễn')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = NoteService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thùng rác',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  const _WarningCard(),
                  const SizedBox(height: 28),
                  Expanded(
                    child: StreamBuilder<List<Note>>(
                      stream: service.watchTrashNotes(),
                      builder: (context, snapshot) {
                        final notes = snapshot.data ?? [];

                        if (notes.isEmpty) {
                          return const _EmptyTrash();
                        }

                        return ListView.separated(
                          itemCount: notes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final n = notes[i];

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.note_outlined, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${n.bookTitle} · Trang ${n.pageNumber}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          n.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFF374151)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Cập nhật: ${_formatDate(n.updatedAt)}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      // ♻️ KHÔI PHỤC
                                      IconButton(
                                        tooltip: 'Khôi phục',
                                        onPressed: () async {
                                          await service.restoreFromTrash(n.id);
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Đã khôi phục ghi chú')),
                                          );
                                        },
                                        icon: const Icon(Icons.restore, color: Color(0xFF16A34A)),
                                      ),

                                      // ❌ XÓA VĨNH VIỄN
                                      IconButton(
                                        tooltip: 'Xóa vĩnh viễn',
                                        onPressed: () => _deleteForever(context, service, n),
                                        icon: const Icon(Icons.delete_forever, color: Color(0xFFEF4444)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Các ghi chú trong thùng rác sẽ tự động bị xóa vĩnh viễn sau 30 ngày',
              style: TextStyle(fontSize: 16, color: Color(0xFF92400E)),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.delete_outline, size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text('Thùng rác trống', style: TextStyle(fontSize: 22, color: Color(0xFF6B7280))),
          SizedBox(height: 8),
          Text('Các ghi chú đã xóa sẽ xuất hiện ở đây', style: TextStyle(color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
