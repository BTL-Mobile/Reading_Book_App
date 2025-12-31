import 'package:flutter/material.dart';
import 'auth_styles.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                const Text(
                  "Reading Station",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thư viện cá nhân của bạn cho việc đọc sách có ý thức",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AuthStyles.subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Thanh chuyển đổi Tab
                      _buildTabSwitcher(),
                      const SizedBox(height: 24),

                      // --- LOGIC HIỂN THỊ FORM Ở ĐÂY ---
                      // Dùng AnimatedSwitcher để có hiệu ứng mờ dần khi chuyển tab (tùy chọn)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isLoginSelected
                            ? const LoginForm(key: ValueKey('login'))
                            : const RegisterForm(key: ValueKey('register')),
                      ),

                      // ----------------------------------
                      const SizedBox(height: 24),
                      _buildFooterDivider(),
                      const SizedBox(height: 24),
                      _buildSocialButtons(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Các Widget phụ trợ (Helper Widgets) ---

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem("Đăng nhập", true),
          _buildTabItem("Đăng ký", false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, bool isLoginTab) {
    bool isActive =
        (isLoginTab && _isLoginSelected) || (!isLoginTab && !_isLoginSelected);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginSelected = isLoginTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                )
              : null,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? const Color(0xFF333333)
                  : AuthStyles.subTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AuthStyles.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AuthStyles.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "hoặc tiếp tục với",
            style: TextStyle(color: AuthStyles.subTextColor, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _socialButtonWithImage("Google", "Assets/images/google.png"),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _socialButtonWithImage(
            "facebook",
            "Assets/images/facebook.png",
          ),
        ),
      ],
    );
  }

  Widget _socialButtonWithImage(String text, String assetPath) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, width: 28, height: 28),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            color: AuthStyles.subTextColor,
            fontSize: 12,
            height: 1.5,
          ),
          children: [
            TextSpan(text: "Bằng cách tiếp tục, bạn đồng ý với "),
            TextSpan(
              text: "Điều khoản dịch vụ\n",
              style: TextStyle(
                color: Color(0xFF00A69C),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: "và "),
            TextSpan(
              text: "Chính sách bảo mật",
              style: TextStyle(
                color: Color(0xFF00A69C),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " của Reading Station"),
          ],
        ),
      ),
    );
  }
}
