import 'package:flutter/material.dart';
import 'auth_styles.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Riêng tab đăng ký có thêm ô Họ tên
        _buildLabel("Họ và tên"),
        const SizedBox(height: 8),
        TextFormField(
          decoration: AuthStyles.inputDecoration(
            hintText: "Nhập tên của bạn",
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel("Email"),
        const SizedBox(height: 8),
        TextFormField(
          decoration: AuthStyles.inputDecoration(
            hintText: "email@example.com",
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel("Mật khẩu"),
        const SizedBox(height: 8),
        TextFormField(
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

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Logic đăng ký ở đây
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthStyles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
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
