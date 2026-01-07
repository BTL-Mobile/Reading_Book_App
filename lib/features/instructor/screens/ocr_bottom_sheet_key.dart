import 'package:flutter/material.dart';

class OCRBottomSheetKey extends StatelessWidget {
  const OCRBottomSheetKey({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OCRBottomSheetKey(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopBar(
                  title: 'Chụp ảnh đoạn văn (OCR)',
                  onClose: () => Navigator.pop(context),
                ),
                const Divider(height: 24),

                _ActionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Chụp ảnh',
                  subtitle: 'Mở camera để chụp đoạn văn',
                  highlight: true,
                  onTap: () {
                    // TODO: mở camera
                  },
                ),

                const SizedBox(height: 18),
                _OrDivider(),

                const SizedBox(height: 18),
                _ActionCard(
                  icon: Icons.upload_outlined,
                  title: 'Tải ảnh lên',
                  subtitle: 'Chọn ảnh từ thư viện',
                  highlight: false,
                  onTap: () {
                    // TODO: chọn ảnh từ gallery
                  },
                ),

                const SizedBox(height: 18),
                _TipBox(),

                const SizedBox(height: 16),
                _CancelButton(onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= COMPONENTS ================= */

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _TopBar({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
          color: const Color(0xFF667085),
          splashRadius: 20,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlight;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlight ? const Color(0xFF9CC1FF) : const Color(0xFFE4E7EC),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: highlight
                  ? const Color(0xFFE8F0FF)
                  : const Color(0xFFF2F4F7),
              child: Icon(
                icon,
                size: 28,
                color: highlight
                    ? const Color(0xFF246BFF)
                    : const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
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
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc',
            style: TextStyle(color: Color(0xFF98A2B3)),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _TipBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7CC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4B400)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Mẹo để OCR chính xác hơn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Chụp trong điều kiện ánh sáng tốt\n'
            '• Giữ máy song song với trang sách\n'
            '• Tránh bóng đổ và chữ bị mờ',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF344054),
          side: const BorderSide(color: Color(0xFFD0D5DD)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Hủy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
