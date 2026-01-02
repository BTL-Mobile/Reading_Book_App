import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'firebase_options.dart';
import 'auth/auth_screen.dart';
import 'package:pht_04/providers/flashcard_provider.dart'; // Import FlashcardProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Bọc ứng dụng trong MultiProvider
    MultiProvider(
      providers: [
        // Khởi tạo FlashcardProvider và nạp dữ liệu mock
        ChangeNotifierProvider(create: (_) => FlashcardProvider()..initData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reading Station',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const AuthScreen(),
    );
  }
}
