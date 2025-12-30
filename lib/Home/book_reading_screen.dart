import 'package:flutter/material.dart';
import 'widgets/table_of_contents_drawer.dart';
import 'widgets/quick_note_sheet.dart';
import '../models/book_model.dart'; // Add this import

class BookReadingScreen extends StatefulWidget {
  final Book book; // Add this
  const BookReadingScreen({
    super.key,
    required this.book,
  }); // Update constructor

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final int _currentPage = 87;
  final int _totalPages = 320;
  final int _currentChapterIndex = 0;

  double get _progress => _currentPage / _totalPages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      drawer: TableOfContentsDrawer(
        currentChapterIndex: _currentChapterIndex,
        onChapterTap: (chapter) {
          print("Đã chọn: ${chapter['title']}");
          Navigator.pop(context);
        },
      ),

      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            widget.book.title, // Use book title
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "James Clear",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined, color: Colors.black),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trang $_currentPage / $_totalPages",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "${(_progress * 100).toInt()}%",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF2D68FF),
              minHeight: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Chương 1: Sức mạnh của thói quen nhỏ\n\n"
            "Vào một ngày tháng Mười năm 2003, tại Anh Quốc, một vị huấn luyện viên đã nhận một công việc khó khăn. Đội tuyển xe đạp Anh Quốc có thành tích tệ hại trong gần một thế kỷ. Kể từ năm 1908, các tay đua người Anh chỉ giành được một huy chương vàng duy nhất tại Thế vận hội Olympic...\n\n(Nội dung giả lập)...",
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF333333),
              fontFamily: 'Times New Roman',
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 14,
                color: Colors.black,
              ),
              label: const Text("Trước", style: TextStyle(color: Colors.black)),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          QuickNoteSheet(currentPage: _currentPage),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                ),

                IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: Colors.black54),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const SizedBox.shrink(),
              label: Row(
                children: const [
                  Text("Tiếp", style: TextStyle(color: Colors.black)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
