import 'package:flutter/material.dart';
import 'package:pht_04/Home/home_screen.dart';
import 'package:pht_04/Review/review_screen.dart';
import 'package:pht_04/Community/community_screen.dart';
import 'package:pht_04/features/instructor/screens/notes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // ✅ Hàm chuyển sang tab Ôn tập
  void _goToReviewTab() => setState(() => _selectedIndex = 2);

  late final List<Widget> _pages = [
    // ✅ Truyền callback sang Home để bấm nút là đổi tab
    HomeScreen(onStartReview: _goToReviewTab),
    const NotesScreen(),
    const ReviewScreen(),
    const CommunityScreen(),
  ];

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
