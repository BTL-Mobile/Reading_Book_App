import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Hàm đăng nhập
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // --- THÊM HÀM ĐĂNG KÝ MỚI ---
  Future<void> register(String email, String password, String name) async {
    try {
      // 1. Tạo tài khoản bên Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Lưu thông tin (Tên) vào Firestore Database
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name, // Lưu họ tên vào đây
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow; // Ném lỗi về UI xử lý
    }
  }

  // Hàm đăng xuất
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
