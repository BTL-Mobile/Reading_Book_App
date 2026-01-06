import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/instructor/screens/notes_screen.dart';
// import 'core/utils/firebase_seeder.dart'; // ❌ tạm thời TẮT seed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(">>> KẾT NỐI FIREBASE THÀNH CÔNG!");

    // ❌ KHÔNG seed tự động mỗi lần chạy
    // await FirebaseSeeder.seedNotes();

  } catch (e) {
    debugPrint(">>> LỖI KẾT NỐI FIREBASE: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Đọc - Instructor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155CFB),
          primary: const Color(0xFF155CFB),
          surface: Colors.white,
        ),
      ),
      home: const NotesScreen(),
    );
  }
}
