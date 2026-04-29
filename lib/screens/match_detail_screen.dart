// File: lib/screens/match_detail_screen.dart
import 'package:flutter/material.dart';

import '../models/match_model.dart';
import '../models/match_detail_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart'; // Import ví chứa ID người dùng
import '../services/auth_service.dart';

// ✅ IMPORT THÊM MAIN SCREEN ĐỂ DÙNG TÍNH NĂNG NHẢY TAB
import 'main_screen.dart';

// CÁC WIDGET GIAO DIỆN
import '../widgets/match_header_widget.dart';
import '../widgets/stats_tab_widget.dart';
import '../widgets/lineups_tab_widget.dart';

class MatchDetailScreen extends StatefulWidget {
  final MatchEvent match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool isLoading = true;
  List<MatchStatItem> stats = [];
  LineupResponse? lineups;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  Future<void> _loadMatchDetails() async {
    try {
      final results = await Future.wait([
        _apiService.fetchMatchStatistics(widget.match.id),
        _apiService.fetchMatchLineups(widget.match.id),
      ]);

      if (mounted) {
        setState(() {
          stats = results[0] as List<MatchStatItem>;
          lineups = results[1] as LineupResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ HÀM FOLLOW ĐÃ ĐƯỢC CHUẨN HÓA LOGIC CHUYỂN TRANG
  Future<void> followTeam(int placeholderUserId, int apiTeamId, String teamName, String logoUrl) async {
    // 1. KIỂM TRA BẢO MẬT: Nếu chưa đăng nhập -> HIỆN BẢNG THÔNG BÁO VÀ CHUYỂN TRANG
    if (UserSession.mySqlUserId == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Yêu cầu đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3C1C5A))),
            content: const Text('Bạn cần đăng nhập để lưu đội bóng này vào danh sách yêu thích của mình.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Bấm Hủy (đóng hộp thoại)
                child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C1C5A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // Đóng hộp thoại thông báo
                  Navigator.of(context).pop();

                  // Xóa sạch lịch sử trang xếp chồng và nhảy về Màn hình chính ở Tab Tài khoản (số 3)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(initialIndex: 3),
                    ),
                        (route) => false,
                  );
                },
                child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
      return; // Dừng hàm lại ở đây, không gọi API nữa
    }

    // 2. NẾU ĐÃ ĐĂNG NHẬP: HIỆN TRẠNG THÁI ĐANG XỬ LÝ
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Đang xử lý...'), duration: Duration(milliseconds: 500)),
      );
    }

    // 3. GỌI API BẰNG DIO (Truyền ID thật từ ví vào)
    bool isSuccess = await _apiService.followTeam(
        UserSession.mySqlUserId!,
        apiTeamId,
        teamName,
        logoUrl
    );

    // 4. BÁO KẾT QUẢ RA MÀN HÌNH
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess ? '✅ Đã theo dõi đội bóng!' : '❌ Lỗi hệ thống hoặc đã theo dõi rồi!'),
          backgroundColor: isSuccess ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Chi tiết trận đấu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: const Color(0xFF3C1C5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Gọi Header Widget và truyền hàm followTeam vào
            MatchHeaderWidget(
              match: widget.match,
              onFollow: followTeam,
            ),

            // Thanh Tab
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF3C1C5A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF3C1C5A),
                tabs: [
                  Tab(text: 'THỐNG KÊ'),
                  Tab(text: 'ĐỘI HÌNH'),
                ],
              ),
            ),

            // Nội dung Tab
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
                  : TabBarView(
                children: [
                  StatsTabWidget(stats: stats),
                  LineupsTabWidget(lineups: lineups),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}