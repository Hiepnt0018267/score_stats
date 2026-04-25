import 'package:flutter/material.dart';
import 'fixtures_tab.dart';
import 'standings_tab.dart';
import 'stats_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Biến lưu vị trí tab đang chọn

  // Danh sách 3 màn hình tương ứng với 3 tab
  final List<Widget> _tabs = [
    const FixturesTab(),
    const StandingsTab(),
    const StatsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình tương ứng với vị trí đang chọn
      body: _tabs[_currentIndex],

      // THANH ĐIỀU HƯỚNG DƯỚI ĐÁY
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Chuyển tab khi bấm
          });
        },
        selectedItemColor: const Color(0xFF3C1C5A),
        // Màu tím Ngoại hạng Anh
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Lịch thi đấu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'Bảng xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}
