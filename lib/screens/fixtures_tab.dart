// File: lib/screens/fixtures_tab.dart
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../widgets/match_card.dart';
import '../widgets/shimmer_loading.dart';
import 'followed_teams_screen.dart';
import 'team_search_screen.dart';

class FixturesTab extends StatefulWidget {
  const FixturesTab({super.key});

  @override
  State<FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends State<FixturesTab> {
  List<MatchEvent> matches = [];
  Set<int> followedTeamIds = {};
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    // 1. Đeo tai nghe: Lắng nghe thay đổi User ID từ bất kỳ đâu (Login/Logout)
    UserSession.userIdNotifier.addListener(_onUserChanged);
    UserSession.followChangeNotifier.addListener(_onFollowChanged);

    // 2. Chạy tải dữ liệu lần đầu
    _loadData();

    // 3. Mẹo nhỏ: Kiểm tra lại sau 1 giây phòng trường hợp ID đến đúng lúc đang dựng màn hình
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && UserSession.mySqlUserId != null && followedTeamIds.isEmpty) {
        _loadData();
      }
    });
  }

  // Hàm tự động chạy khi nhận tín hiệu từ UserSession
  void _onUserChanged() {
    if (mounted) {
      print("FixturesTab: Nhan tin hieu doi User, dang tai lai du lieu...");
      _loadData();
    }
  }
  void _onFollowChanged() {
    if (mounted) {
      print("🔔 FixturesTab: Nghe chuông Follow thay đổi, đang tải lại dữ liệu...");
      _loadData();
    }
  }

  @override
  void dispose() {
    // Tháo tai nghe để tránh lỗi bộ nhớ
    UserSession.userIdNotifier.removeListener(_onUserChanged);
    UserSession.followChangeNotifier.removeListener(_onFollowChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    // Đảm bảo không gọi setState nếu Widget đã bị hủy
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // BƯỚC 1: Luôn tải lịch thi đấu gốc
      List<MatchEvent> allMatches = await _apiService.fetchPremierLeagueMatches();

      // BƯỚC 2: Kiểm tra ID người dùng hiện tại
      int? currentUserId = UserSession.mySqlUserId;

      if (currentUserId != null) {
        // BƯỚC 3: Nếu đã có ID, lấy danh sách đội đã Follow từ Spring Boot
        final followedData = await _apiService.getFollowedTeams(currentUserId);
        followedTeamIds = followedData.map((t) => int.parse(t['apiId'].toString())).toSet();

        // BƯỚC 4: Sắp xếp ưu tiên các trận có đội yêu thích lên đầu
        allMatches.sort((a, b) {
          bool isAFavorite = followedTeamIds.contains(a.homeTeam.id) || followedTeamIds.contains(a.awayTeam.id);
          bool isBFavorite = followedTeamIds.contains(b.homeTeam.id) || followedTeamIds.contains(b.awayTeam.id);

          if (isAFavorite && !isBFavorite) return -1;
          if (!isAFavorite && isBFavorite) return 1;
          return 0;
        });
      } else {
        // Nếu không có ID (chưa login hoặc đăng xuất), làm sạch bộ lọc
        followedTeamIds.clear();
      }

      if (mounted) {
        setState(() {
          matches = allMatches;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Loi tai du lieu tai FixturesTab: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Lịch thi đấu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamSearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FollowedTeamsScreen())),
          ),
        ],
      ),
      body: isLoading && matches.isEmpty
          ? const Center(child: MatchShimmerLoading())
          : matches.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Khong co du lieu thoi gian nay', style: TextStyle(color: Colors.grey)),
            TextButton(onPressed: _loadData, child: const Text('Thu lai'))
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF3C1C5A),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final isFavoriteMatch = followedTeamIds.contains(match.homeTeam.id) || followedTeamIds.contains(match.awayTeam.id);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFavoriteMatch)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFE90052), size: 16),
                        SizedBox(width: 4),
                        Text('Dành cho bạn', style: TextStyle(color: Color(0xFFE90052), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                MatchCard(match: match),
              ],
            );
          },
        ),
      ),
    );
  }
}