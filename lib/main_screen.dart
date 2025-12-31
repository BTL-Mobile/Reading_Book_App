import 'package:flutter/material.dart';
import 'package:pht_04/Home/home_screen.dart';
import 'package:pht_04/Review/review_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text('Màn hình Ghi chú')),
    const ReviewScreen(),
    const Center(child: Text('Màn hình Cộng đồng')),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4C4DDC),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Thư viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Ghi chú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Ôn tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Cộng đồng',
          ),
        ],
      ),
    );
  }
}
