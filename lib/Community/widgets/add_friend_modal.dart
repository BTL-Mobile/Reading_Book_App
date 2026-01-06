import 'package:flutter/material.dart';
import '../../services/community_service.dart';

class AddFriendModal extends StatefulWidget {
  const AddFriendModal({super.key});

  @override
  State<AddFriendModal> createState() => _AddFriendModalState();
}

class _AddFriendModalState extends State<AddFriendModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- LOGIC 1: TÌM KIẾM ---
  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final results = await CommunityService().searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: KẾT BẠN ---
  void _handleAddFriend(Map<String, dynamic> user) async {
    try {
      await CommunityService().addFriend(
        friendId: user['uid'],
        friendName: user['name'] ?? "Người dùng ẩn",
        friendAvatar: user['photoUrl'] ?? "https://i.pravatar.cc/150",
        booksRead: user['booksReadCount'] ?? 0,
        readingBook: user['currentReading'] ?? "Chưa đọc sách nào",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã thêm ${user['name']} vào danh sách bạn bè!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding này giúp modal đẩy lên khi bàn phím hiện
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thêm bạn bè",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // --- NỘI DUNG ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Ô TÌM KIẾM
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Nhập tên người dùng...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ĐIỀU KIỆN HIỂN THỊ
                  if (_isSearching) ...[
                    // TRƯỜNG HỢP A: ĐANG TÌM
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    // KHÔNG TÌM THẤY
                    else if (_searchResults.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Không tìm thấy ai tên \"${_searchCtrl.text}\"",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    // CÓ KẾT QUẢ
                    else ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Kết quả tìm kiếm",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ..._searchResults.map((user) => _buildUserItem(user)),
                    ],
                  ] else ...[
                    // TRƯỜNG HỢP B: HIỆN GỢI Ý (MẶC ĐỊNH)
                    _buildSuggestions(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DANH SÁCH GỢI Ý (FUTURE BUILDER) ---
  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner xanh
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Gợi ý kết bạn từ cộng đồng Trạm Đọc",
                  style: TextStyle(color: Colors.blue[800], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 👇👇 QUAN TRỌNG: LẤY DỮ LIỆU TỪ DATABASE, KHÔNG DÙNG TÊN GIẢ NỮA 👇👇
        FutureBuilder<List<Map<String, dynamic>>>(
          future: CommunityService().getSuggestedUsers(),
          builder: (context, snapshot) {
            // 1. Đang tải
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // 2. Có lỗi
            if (snapshot.hasError) {
              print(
                "Lỗi gợi ý: ${snapshot.error}",
              ); // In lỗi ra console để debug
              return const Text("Không thể tải gợi ý lúc này.");
            }

            final users = snapshot.data ?? [];

            // 3. Không có user nào (Hoặc chỉ có 1 mình trong DB)
            if (users.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Text(
                  "Chưa có người dùng nào khác để gợi ý.\nHãy tạo thêm user trong Firestore để test.",
                ),
              );
            }

            // 4. Hiển thị danh sách
            return Column(
              children: users.map((user) {
                return _buildUserItem(user);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET DÒNG USER (DÙNG CHUNG) ---
  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              user['photoUrl'] ?? "https://i.pravatar.cc/150",
            ),
            radius: 26,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? "Người dùng ẩn",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${user['booksReadCount'] ?? 0} sách đã đọc",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  "Đang đọc: ${user['currentReading'] ?? 'Chưa rõ'}",
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleAddFriend(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Kết bạn",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
