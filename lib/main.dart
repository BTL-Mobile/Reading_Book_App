import 'package:flutter/material.dart';
import 'features/instructor/screens/notes_screen.dart';
import 'features/instructor/screens/note_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Book App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Hoặc 'Arimo' nếu đã cài font
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const NotesScreen(),
        '/note_detail': (context) => const NoteDetailScreen(),
      },
    );
  }
}