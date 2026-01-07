import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // nhìn phát biết ngay
      appBar: AppBar(title: const Text('GHI CHÚ - TEST')),
      body: const Center(
        child: Text(
          'Nếu thấy nền đỏ + chữ này là OK',
          style: TextStyle(fontSize: 22, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
