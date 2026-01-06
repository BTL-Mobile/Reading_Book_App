import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. TÌM KIẾM BẠN BÈ
  Future<List<Map<String, dynamic>>> searchUsers(String queryName) async {
    if (queryName.isEmpty) return [];

    final result = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: queryName)
        .where('name', isLessThan: queryName + 'z')
        .limit(10)
        .get();

    return result.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      if (data['photoUrl'] == null) {
        data['photoUrl'] = "https://i.pravatar.cc/150?u=${doc.id}";
      }
      return data;
    }).toList();
  }

  // 2. KẾT BẠN (Cập nhật: Lưu đầy đủ thông tin để hiển thị cho đẹp)
  Future<void> addFriend({
    required String friendId,
    required String friendName,
    required String friendAvatar,
    required int booksRead,
    required String readingBook,
  }) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    // Lưu đầy đủ thông tin vào sub-collection friends
    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendId)
        .set({
          'addedAt': FieldValue.serverTimestamp(),
          'name': friendName,
          'photoUrl': friendAvatar, // <--- Lưu thêm
          'booksReadCount': booksRead, // <--- Lưu thêm
          'currentReading': readingBook, // <--- Lưu thêm
        });
  }

  // 3. LẤY DANH SÁCH BẠN BÈ (Hàm mới)
  Stream<QuerySnapshot> getFriendsList() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // 4. LẤY FEED
  Stream<QuerySnapshot> getGlobalFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // 5. ĐĂNG BÀI
  Future<void> createPost({
    required String bookTitle,
    required String type,
    required String content,
    int? rating,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('posts').add({
      'userId': user.uid,
      'userName': user.displayName ?? "Người dùng ẩn",
      'userAvatar': user.photoURL,
      'bookTitle': bookTitle,
      'type': type,
      'content': content,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Thay thế hàm cũ bằng hàm này để xem lỗi ở đâu
  Future<List<Map<String, dynamic>>> getSuggestedUsers() async {
    final currentUid = _auth.currentUser?.uid;
    print("🔍 DEBUG: ID của tôi là: $currentUid");

    try {
      // 1. Thử lấy dữ liệu thô từ Firestore
      final result = await _firestore.collection('users').limit(10).get();
      print("🔍 DEBUG: Tìm thấy ${result.docs.length} users trong database");

      if (result.docs.isEmpty) {
        print("⚠️ DEBUG: Collection 'users' đang trống hoặc sai tên!");
        return [];
      }

      final List<Map<String, dynamic>> finalResult = [];

      for (var doc in result.docs) {
        final data = doc.data();
        data['uid'] = doc.id; // Gán ID của document vào biến uid

        // Log từng user tìm được
        print(" --> Tìm thấy User: ID=${doc.id}, Tên=${data['name']}");

        // Xử lý avatar
        if (data['photoUrl'] == null) {
          data['photoUrl'] = "https://i.pravatar.cc/150?u=${doc.id}";
        }

        // Logic lọc trùng
        if (doc.id != currentUid) {
          finalResult.add(data);
        } else {
          print(" --> (Đã ẩn bản thân khỏi danh sách gợi ý)");
        }
      }

      print("✅ DEBUG: Kết quả cuối cùng trả về ${finalResult.length} người");
      return finalResult;
    } catch (e) {
      print("❌ LỖI NGHIÊM TRỌNG: $e");
      // Nếu lỗi là permission-denied thì do Rules
      return [];
    }
  }
}
