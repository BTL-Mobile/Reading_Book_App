import 'package:flutter/material.dart';

class ReviewAnswerButtons extends StatelessWidget {
  final bool enabled;
  final void Function(int grade) onAnswer;

  const ReviewAnswerButtons({
    super.key,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Bạn nhớ nội dung này như thế nào?',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AnsTile(
                  enabled: enabled,
                  title: '😰 Quên rồi',
                  subtitle: 'Ôn lại sau 10 phút',
                  bg: const Color(0xFFFFE0E0),
                  onTap: () => onAnswer(0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnsTile(
                  enabled: enabled,
                  title: '🤔 Khó nhớ',
                  subtitle: 'Ôn lại sau 1 ngày',
                  bg: const Color(0xFFFFEFD4),
                  onTap: () => onAnswer(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AnsTile(
                  enabled: enabled,
                  title: '👍 Nhớ được',
                  subtitle: 'Ôn lại sau 3 ngày',
                  bg: const Color(0xFFDFFBE6),
                  onTap: () => onAnswer(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnsTile(
                  enabled: enabled,
                  title: '😎 Dễ ợt',
                  subtitle: 'Ôn lại sau 1 tuần',
                  bg: const Color(0xFFDBEAFE),
                  onTap: () => onAnswer(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnsTile extends StatelessWidget {
  final bool enabled;
  final String title;
  final String subtitle;
  final Color bg;
  final VoidCallback onTap;

  const _AnsTile({
    required this.enabled,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
