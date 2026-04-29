// File: lib/screens/main_screen.dart
import 'package:flutter/material.dart';

// Nhập 4 màn hình Tab
import 'fixtures_tab.dart';
import 'standings_tab.dart';
import 'stats_tab.dart';
import 'account_tab.dart';

// THÊM DÒNG NÀY ĐỂ GỌI HÀM KHÔI PHỤC ĐĂNG NHẬP
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex; // ✅ BƯỚC 1: Thêm biến nhận diện Tab

  // ✅ BƯỚC 2: Thêm initialIndex vào constructor, mặc định là 0
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex; // ✅ BƯỚC 3: Sửa thành 'late' để chờ nhận dữ liệu

  final List<Widget> _tabs = [
    const FixturesTab(),
    const StandingsTab(),
    const StatsTab(),
    const AccountTab(), // Đây là Tab số 3
  ];

  // HÀM NÀY CHẠY 1 LẦN DUY NHẤT KHI VỪA MỞ APP
  @override
  void initState() {
    super.initState();

    // ✅ BƯỚC 4: Gán giá trị tab lúc khởi động bằng biến được truyền vào
    _currentIndex = widget.initialIndex;

    // Khôi phục phiên làm việc: Kiểm tra Firebase và lấy MySQL ID
    AuthService().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE90052), // Màu hồng đỏ nổi bật
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Trận đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Bảng xếp hạng'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}