import 'package:flutter/material.dart';

class NoteDetailUiKey extends StatelessWidget {
  const NoteDetailUiKey({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _HeaderBlue(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _NoteContentCard(),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.edit,
                    label: 'Chỉnh sửa',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Chuyển sang sách khác',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _WarningButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Xóa khỏi Flashcard',
                    bgColor: const Color(0xFFFFF4CC),
                    textColor: const Color(0xFFD97706),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _DangerButton(
                    label: 'Xóa vĩnh viễn',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= HEADER ================= */

class _HeaderBlue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF246BFF), Color(0xFF4F46E5)],
        ),
      ),
      child: Column(
        children: const [
          Text(
            'Trạm Đọc',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Trợ lý đọc sách chủ động & ghi nhớ',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= NOTE CARD ================= */

class _NoteContentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4B400), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Atomic Habits',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Trang 15',
            style: TextStyle(fontSize: 18, color: Color(0xFF667085)),
          ),
          Divider(height: 28),
          Text(
            'Thói quen tốt là nền tảng cho sự thành công. '
            'Quy tắc 1%: Cải thiện mỗi ngày 1% sẽ tạo ra sự khác biệt lớn sau 1 năm.',
            style: TextStyle(fontSize: 20, height: 1.4),
          ),
          Divider(height: 28),
          Text(
            'Tạo lúc: lúc 07:00 Thứ Bảy, 16 tháng 11, 2024',
            style: TextStyle(fontSize: 16, color: Color(0xFF667085)),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniButton(
                  icon: Icons.copy,
                  label: 'Sao chép',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniButton(
                  icon: Icons.share,
                  label: 'Chia sẻ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= BUTTONS ================= */

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF246BFF)),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(fontSize: 20),
        side: const BorderSide(color: Color(0xFFD0D5DD)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _WarningButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _WarningButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          textStyle: const TextStyle(fontSize: 20),
          side: const BorderSide(color: Color(0xFFFFC7C7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
