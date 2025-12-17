import 'package:flutter/material.dart';
// Import màn hình trang chủ (Danh sách ghi chú)
import 'features/instructor/screens/notes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Đọc - Instructor',
      debugShowCheckedModeBanner: false, // Tắt cái dải băng Debug màu đỏ ở góc phải

      // Cấu hình giao diện chung (Theme) cho toàn bộ App
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Bạn có thể đổi thành 'Arimo' nếu đã thêm font vào pubspec.yaml

        // Màu nền chung cho các màn hình (Xám rất nhạt chuẩn Figma)
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),

        // Cấu hình màu sắc chủ đạo (Xanh dương)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155CFB),
          primary: const Color(0xFF155CFB),
          // Màu nền surface (các hộp thoại, card...)
          surface: Colors.white,
        ),

        // Cấu hình mặc định cho AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // Giữ màu trắng thuần, không bị ám màu
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),

        // Cấu hình mặc định cho nút bấm (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF155DFC), // Màu nền nút
            foregroundColor: Colors.white, // Màu chữ nút
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bo góc 10px
            ),
            elevation: 0, // Không đổ bóng
          ),
        ),

        // Cấu hình mặc định cho ô nhập liệu (Input)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.5),
          ),
        ),
      ),

      // Màn hình khởi động đầu tiên
      home: const NotesScreen(),
    );
  }
}