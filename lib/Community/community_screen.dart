import 'package:flutter/material.dart';
// Import các widget con
import 'widgets/post_card.dart';
import 'widgets/friend_card.dart';
import 'widgets/community_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0; // 0: Hoạt động, 1: Bạn bè

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Nền xám nhạt
      body: Column(
        children: [
          // 1. Header (Tách ra file community_widgets.dart)
          const CommunityAppHeader(),

          // 2. Nội dung cuộn
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SocialHeader(),

                  const SizedBox(height: 16),

                  // Tabs
                  CommunityTabs(
                    selectedTab: _selectedTab,
                    onTabSelected: (index) {
                      setState(() => _selectedTab = index);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Nội dung chính
                  if (_selectedTab == 0)
                    _buildActivitiesList()
                  else
                    _buildFriendsList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Danh sách Hoạt động (Dùng PostCard)
  Widget _buildActivitiesList() {
    return const Column(
      children: [
        PostCard(
          avatarUrl: "https://i.pravatar.cc/150?img=11",
          userName: "Nguyễn Văn A",
          action: "đã đọc xong",
          time: "2 giờ trước",
          bookTitle: "The Psychology of Money",
          bookCoverColor: Colors.blueGrey,
          rating: 5,
          comment: "A đánh giá cao cuốn sách này",
          type: PostType.rating,
        ),
        SizedBox(height: 16),
        PostCard(
          avatarUrl: "https://i.pravatar.cc/150?img=5",
          userName: "Trần Thị B",
          action: "ghi chú từ",
          time: "5 giờ trước",
          bookTitle: "Sapiens",
          bookCoverColor: Colors.brown,
          quote:
              "“Khả năng tưởng tượng tập thể là điều làm con người khác biệt” - một insight thật sâu sắc!",
          type: PostType.note,
        ),
        SizedBox(height: 16),
        PostCard(
          avatarUrl: "https://i.pravatar.cc/150?img=3",
          userName: "Lê Văn C",
          action: "thêm vào kệ \"Muốn đọc\"",
          time: "Hôm qua",
          bookTitle: "The Lean Startup",
          bookCoverColor: Colors.amber,
          type: PostType.wishlist,
        ),
        SizedBox(height: 24),
        TrendingSection(),
        SizedBox(height: 16),
        InfoCard(
          title: "Tại sao \"Mạng xã hội\"?",
          content:
              "Thay vì theo dõi hàng nghìn người lạ, bạn chỉ kết nối với những người mà bạn thực sự tin tưởng.",
        ),
      ],
    );
  }

  // Danh sách Bạn bè (Dùng FriendCard)
  Widget _buildFriendsList() {
    return const Column(
      children: [
        FriendCard(
          avatarUrl: "https://i.pravatar.cc/150?img=11",
          name: "Nguyễn Văn A",
          bookCount: 24,
          readingBook: "The Lean Startup",
        ),
        SizedBox(height: 16),
        FriendCard(
          avatarUrl: "https://i.pravatar.cc/150?img=5",
          name: "Trần Thị B",
          bookCount: 18,
          readingBook: "Sapiens",
        ),
        SizedBox(height: 16),
        FriendCard(
          avatarUrl: "https://i.pravatar.cc/150?img=3",
          name: "Lê Văn C",
          bookCount: 32,
          readingBook: "Atomic Habits",
        ),
        SizedBox(height: 24),
        InviteFriendCard(),
        SizedBox(height: 24),
        InfoCard(
          title: "Tại sao \"Mạng xã hội lại đáng tin cậy\"?",
          content:
              "Gợi ý sách từ bạn bè thân thiết có giá trị hơn gấp nhiều lần so với thuật toán!",
        ),
      ],
    );
  }
}
