import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Auth import removed because it's not used in this file
import 'package:intl/intl.dart'; // Để format ngày tháng nếu cần

// Import các file con (Đảm bảo đường dẫn đúng với dự án của bạn)
import '../../services/community_service.dart';
import 'widgets/post_card.dart';
import 'widgets/friend_card.dart';
import 'widgets/community_widgets.dart';
import 'widgets/create_post_modal.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0; // 0: Hoạt động, 1: Bạn bè
  // FirebaseAuth instance not used directly here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2962FF),
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Để đẩy lên khi có bàn phím
            backgroundColor: Colors.transparent,
            builder: (context) => const CreatePostModal(),
          );
        },
      ), // Nền xám nhạt
      body: Column(
        children: [
          // 1. Header Xanh (Từ file community_widgets.dart)
          const CommunityAppHeader(),

          // 2. Nội dung cuộn
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header Mạng xã hội + Nút Thêm
                  const SocialHeader(),

                  const SizedBox(height: 16),

                  // Tabs chuyển đổi (Hoạt động / Bạn bè)
                  CommunityTabs(
                    selectedTab: _selectedTab,
                    onTabSelected: (index) {
                      setState(() => _selectedTab = index);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Nội dung chính thay đổi theo Tab
                  if (_selectedTab == 0)
                    _buildActivitiesFeed() // <--- Đã kết nối Firestore
                  else
                    _buildFriendsList(), // Danh sách bạn bè (Tĩnh/Mock)

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PHẦN 1: FEED HOẠT ĐỘNG (REAL-TIME)
  // ==========================================
  Widget _buildActivitiesFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: CommunityService().getGlobalFeed(), // Lắng nghe dữ liệu
      builder: (context, snapshot) {
        // 1. Đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Có lỗi
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];

        // 3. Danh sách trống
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.feed_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  "Chưa có hoạt động nào.\nHãy là người đầu tiên đăng bài!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // 4. Hiển thị danh sách
        return Column(
          children: [
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Xử lý loại bài viết (Convert String -> Enum)
              PostType type = PostType.rating;
              if (data['type'] == 'note') type = PostType.note;
              if (data['type'] == 'wishlist') type = PostType.wishlist;

              // Xử lý thời gian
              String timeDisplay = "Vừa xong";
              if (data['createdAt'] != null) {
                final Timestamp timestamp = data['createdAt'];
                timeDisplay = _getTimeAgo(timestamp.toDate());
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PostCard(
                  avatarUrl: data['userAvatar'] ?? "https://i.pravatar.cc/150",
                  userName: data['userName'] ?? "Người dùng ẩn",
                  action: _getActionText(data['type']),
                  time: timeDisplay,
                  bookTitle: data['bookTitle'] ?? "Sách chưa đặt tên",
                  bookCoverColor: _getBookColor(data['bookTitle']),
                  type: type,
                  rating: data['rating'] != null
                      ? (data['rating'] as num).toInt()
                      : null,
                  comment: data['content'],
                  quote:
                      data['content'], // Với Note, content đóng vai trò là quote
                ),
              );
            }).toList(),

            // Phần widget phụ bên dưới Feed
            const SizedBox(height: 8),
            const TrendingSection(),
            const SizedBox(height: 16),
            const InfoCard(
              title: "Tại sao \"Mạng xã hội\"?",
              content:
                  "Thay vì theo dõi hàng nghìn người lạ, bạn chỉ kết nối với những người mà bạn thực sự tin tưởng.",
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // PHẦN 2: DANH SÁCH BẠN BÈ (REAL-TIME)
  // ==========================================
  // Tìm hàm này trong community_screen.dart và thay thế nội dung bên trong
  Widget _buildFriendsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: CommunityService()
          .getFriendsList(), // <--- Lắng nghe dữ liệu thật từ Firestore
      builder: (context, snapshot) {
        // 1. Đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // 2. Chưa kết bạn với ai
        if (docs.isEmpty) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_disabled,
                      size: 50,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Bạn chưa có bạn bè nào.\nBấm nút 'Thêm' để kết nối nhé!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const InviteFriendCard(),
            ],
          );
        }

        // 3. Hiển thị danh sách bạn bè thật
        return Column(
          children: [
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FriendCard(
                  avatarUrl: data['photoUrl'] ?? "https://i.pravatar.cc/150",
                  name: data['name'] ?? "Không tên",
                  bookCount: data['booksReadCount'] ?? 0,
                  readingBook: data['currentReading'] ?? "Không rõ",
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
            const InviteFriendCard(),
          ],
        );
      },
    );
  }
  // ==========================================
  // CÁC HÀM TIỆN ÍCH (HELPER)
  // ==========================================

  // 1. Sinh text hành động dựa trên loại post
  String _getActionText(String? type) {
    if (type == 'rating') return "đã đọc xong";
    if (type == 'note') return "ghi chú từ";
    if (type == 'wishlist') return "muốn đọc";
    return "vừa đăng";
  }

  // 2. Sinh màu bìa sách ngẫu nhiên theo tên sách (để đỡ bị trùng màu)
  Color _getBookColor(String? title) {
    if (title == null || title.isEmpty) return Colors.blue;
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    // Dùng mã hash của tên sách để chọn màu cố định cho sách đó
    return colors[title.hashCode.abs() % colors.length];
  }

  // 3. Tính thời gian tương đối (Vd: 5 phút trước)
  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
