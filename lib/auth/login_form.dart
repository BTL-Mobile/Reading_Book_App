import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../Home/home_screen.dart';
import 'auth_styles.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // 1. Khởi tạo Service để xử lý logic
  final AuthService _authService = AuthService();

  // 2. Controller để lấy dữ liệu nhập vào
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // 3. Các biến trạng thái giao diện
  bool _isObscure = true; // Ẩn/hiện mật khẩu
  bool _isLoading = false; // Trạng thái đang tải (quay vòng tròn)

  // --- HÀM XỬ LÝ ĐĂNG NHẬP ---
  Future<void> _handleLogin() async {
    // Ẩn bàn phím khi bấm nút
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    // Bước 1: Kiểm tra dữ liệu đầu vào (Validation)
    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng nhập đầy đủ Email và Mật khẩu!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Bước 2: Bật trạng thái Loading
    setState(() => _isLoading = true);

    try {
      // Bước 3: Gọi qua Service để đăng nhập
      await _authService.login(email, password);

      // Bước 4: Nếu thành công (không bị lỗi) -> Chuyển trang
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Bước 5: Xử lý các lỗi từ Firebase trả về
      String message = "Đăng nhập thất bại";

      switch (e.code) {
        case 'user-not-found':
          message = "Tài khoản email này chưa được đăng ký.";
          break;
        case 'wrong-password':
          message = "Sai mật khẩu, vui lòng thử lại.";
          break;
        case 'invalid-email':
          message = "Định dạng email không hợp lệ.";
          break;
        case 'user-disabled':
          message = "Tài khoản này đã bị vô hiệu hóa.";
          break;
        case 'too-many-requests':
          message = "Đăng nhập sai quá nhiều lần. Vui lòng thử lại sau.";
          break;
        default:
          message = "Lỗi: ${e.message}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Các lỗi hệ thống khác
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã xảy ra lỗi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Bước 6: Tắt trạng thái Loading dù thành công hay thất bại
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Ô NHẬP EMAIL ---
        _buildLabel("Email"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
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
          controller: _passController,
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

        // --- QUÊN MẬT KHẨU ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Xử lý quên mật khẩu sau
            },
            child: const Text(
              "Quên mật khẩu?",
              style: TextStyle(
                color: Color(0xFF00A69C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // --- NÚT ĐĂNG NHẬP ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            // Nếu đang loading thì disable nút (null)
            onPressed: _isLoading ? null : _handleLogin,
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
                    "Đăng nhập",
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
