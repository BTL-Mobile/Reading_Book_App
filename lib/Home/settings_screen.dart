import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 1. Khởi tạo Service
  final AuthService _authService = AuthService();

  // Các biến trạng thái cho giao diện (Switch)
  bool _remindStudy = true;
  bool _remindSession = true;
  bool _readingCircle = false;

  // --- HÀM XỬ LÝ ĐĂNG XUẤT ---
  Future<void> _handleLogout() async {
    try {
      // Gọi Service để đăng xuất khỏi Firebase
      await _authService.logout();

      // Kiểm tra xem màn hình còn tồn tại không trước khi chuyển trang
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi đăng xuất: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Màu nền kem nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D68FF), // Màu xanh chủ đạo
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cài đặt tài khoản",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Phần Tùy chọn thông báo
            _buildSectionContainer(
              title: "Tùy chọn thông báo",
              icon: Icons.notifications_none,
              children: [
                _buildSwitchTile(
                  "Nhắc nhở ôn tập hàng ngày",
                  "Nhận nhắc nhở để hoàn thành bài ôn tập hàng ngày",
                  _remindStudy,
                  (val) => setState(() => _remindStudy = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Ô chọn giờ (Giả lập)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Thời gian nhắc nhở",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "20:00",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  "Nhắc nhở phiên ôn tập",
                  "Thông báo khi đến lượt ôn flashcard",
                  _remindSession,
                  (val) => setState(() => _remindSession = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSwitchTile(
                  "Hoạt động Vòng tròn đọc sách",
                  "Nhận thông báo khi bạn bè hoàn thành sách",
                  _readingCircle,
                  (val) => setState(() => _readingCircle = val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Phần Bảo mật
            _buildSectionContainer(
              title: "Bảo mật",
              icon: Icons.security,
              children: [
                _buildListTile(
                  "Đổi mật khẩu",
                  "Cập nhật mật khẩu tài khoản của bạn",
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildListTile(
                  "Xác thực hai yếu tố",
                  "Thêm lớp bảo mật bổ sung",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Phần Dữ liệu & Đồng bộ
            _buildSectionContainer(
              title: "Dữ liệu & Đồng bộ",
              icon: Icons.storage_outlined,
              children: [
                _buildListTile(
                  "Xuất dữ liệu của tôi",
                  "Tải xuống lịch sử đọc sách của bạn",
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  title: const Text(
                    "Dung lượng sử dụng",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    "Đã dùng 12.4 MB / 100 MB",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Các mục thông tin khác
            _buildSimpleTile("Chính sách bảo mật"),
            _buildSimpleTile("Điều khoản dịch vụ"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Phiên bản ứng dụng",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text("1.0.0", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 5. NÚT ĐĂNG XUẤT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleLogout, // Gọi hàm đăng xuất
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Đăng xuất",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Container chung cho mỗi phần (Section)
  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2D68FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Mục Switch (Bật/Tắt)
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2D68FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  // Mục List Tile thông thường (có mũi tên)
  Widget _buildListTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {},
    );
  }

  // Mục đơn giản (cho Chính sách, điều khoản...)
  Widget _buildSimpleTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {},
      ),
    );
  }
}
