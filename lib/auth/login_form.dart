import 'package:flutter/material.dart';
import 'auth_styles.dart'; // Import file style

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
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
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Logic đăng nhập ở đây
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthStyles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
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
