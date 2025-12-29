import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Nhớ import Service
import '../Home/home_screen.dart';
import 'auth_styles.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // 1. Khởi tạo Service
  final AuthService _authService = AuthService();

  // 2. Khởi tạo 3 Controllers (Thêm cái NameController)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  // --- HÀM XỬ LÝ ĐĂNG KÝ ---
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    // Bước 1: Validation (Kiểm tra rỗng)
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng nhập đầy đủ Họ tên, Email và Mật khẩu!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Bước 2: Loading
    setState(() => _isLoading = true);

    try {
      // Bước 3: Gọi hàm register từ AuthService (Có truyền thêm name)
      await _authService.register(email, password, name);

      // Bước 4: Thành công -> Vào Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tạo tài khoản thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đặc thù của Đăng ký
      String message = "Đăng ký thất bại";
      String errorString = e.code.toLowerCase(); // Lấy mã lỗi

      if (errorString.contains('weak-password')) {
        message = "Mật khẩu quá yếu (cần ít nhất 6 ký tự).";
      } else if (errorString.contains('email-already-in-use')) {
        message = "Email này đã được sử dụng bởi tài khoản khác.";
      } else if (errorString.contains('invalid-email')) {
        message = "Email không hợp lệ.";
      } else {
        message = "Lỗi: ${e.message}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Xử lý lỗi trên Web hoặc lỗi khác
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Ô NHẬP HỌ TÊN ---
        _buildLabel("Họ và tên"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController, // Gắn controller
          decoration: AuthStyles.inputDecoration(
            hintText: "Nhập tên của bạn",
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),

        // --- Ô NHẬP EMAIL ---
        _buildLabel("Email"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController, // Gắn controller
          decoration: AuthStyles.inputDecoration(
            hintText: "email@example.com",
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),

        // --- Ô NHẬP PASSWORD ---
        _buildLabel("Mật khẩu"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passController, // Gắn controller
          obscureText: _isObscure,
          decoration: AuthStyles.inputDecoration(
            hintText: "••••••••",
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _isObscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- NÚT TẠO TÀI KHOẢN ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister, // Gọi hàm xử lý
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthStyles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Tạo tài khoản",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AuthStyles.subTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
