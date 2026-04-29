// File: lib/screens/team_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../widgets/match_card.dart';

// ✅ IMPORT THÊM 2 FILE NÀY ĐỂ XỬ LÝ FOLLOW VÀ ĐĂNG NHẬP
import '../services/user_session.dart';
import 'main_screen.dart';

class TeamProfileScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String logoUrl;

  const TeamProfileScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.logoUrl,
  });

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  final ApiService _apiService = ApiService();

  // Biến cho Lịch thi đấu
  List<MatchEvent> lastMatches = [];
  List<MatchEvent> nextMatches = [];
  bool isLoading = true;

  // ✅ BIẾN CHO NÚT FOLLOW
  bool isFollowed = false;
  bool isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
    _checkFollowStatus(); // Gọi thêm hàm check Follow lúc mở trang
  }

  // Lấy dữ liệu trận đấu
  Future<void> _loadTeamData() async {
    final results = await Future.wait([
      _apiService.fetchTeamMatches(widget.teamId, 'last'),
      _apiService.fetchTeamMatches(widget.teamId, 'next'),
    ]);

    if (mounted) {
      setState(() {
        lastMatches = results[0];
        nextMatches = results[1];
        isLoading = false;
      });
    }
  }

  // ✅ HÀM KIỂM TRA TRẠNG THÁI FOLLOW
  Future<void> _checkFollowStatus() async {
    if (UserSession.mySqlUserId != null) {
      try {
        final teams = await _apiService.getFollowedTeams(UserSession.mySqlUserId!);
        final followedIds = teams.map((t) => int.parse(t['apiId'].toString())).toSet();

        if (mounted) {
          setState(() {
            isFollowed = followedIds.contains(widget.teamId);
            isLoadingStatus = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoadingStatus = false);
      }
    } else {
      if (mounted) setState(() => isLoadingStatus = false);
    }
  }

  // ✅ HÀM XỬ LÝ KHI BẤM NÚT FOLLOW / UNFOLLOW
  Future<void> _toggleFollow() async {
    if (UserSession.mySqlUserId == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Yêu cầu đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3C1C5A))),
            content: Text('Bạn cần đăng nhập để theo dõi đội ${widget.teamName}.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C1C5A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 3)),
                        (route) => false,
                  );
                },
                child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
      return;
    }

    if (isFollowed) {
      bool success = await _apiService.unfollowTeam(UserSession.mySqlUserId!, widget.teamId);
      if (success && mounted) {
        setState(() => isFollowed = false);
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã bỏ theo dõi ${widget.teamName}')));
      }
    } else {
      bool success = await _apiService.followTeam(UserSession.mySqlUserId!, widget.teamId, widget.teamName, widget.logoUrl);
      if (success && mounted) {
        setState(() => isFollowed = true);
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã theo dõi ${widget.teamName}'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(widget.teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF3C1C5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // HEADER: HIỂN THỊ LOGO VÀ NÚT FOLLOW
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.logoUrl,
                    httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.shield, size: 100, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.teamName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3C1C5A)),
                  ),
                  const SizedBox(height: 15),

                  // ✅ NÚT FOLLOW THẦN THÁNH NẰM Ở ĐÂY
                  isLoadingStatus
                      ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(color: Color(0xFFE90052))))
                      : ElevatedButton.icon(
                    onPressed: _toggleFollow,
                    icon: Icon(
                      isFollowed ? Icons.favorite : Icons.favorite_border,
                      color: isFollowed ? Colors.white : const Color(0xFFE90052),
                    ),
                    label: Text(
                      isFollowed ? 'Đã ghim đội này' : 'Theo dõi ngay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFollowed ? Colors.white : const Color(0xFFE90052),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowed ? const Color(0xFFE90052) : Colors.white,
                      foregroundColor: isFollowed ? Colors.white : const Color(0xFFE90052),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      side: const BorderSide(color: Color(0xFFE90052), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: isFollowed ? 5 : 0,
                    ),
                  ),
                ],
              ),
            ),

            // THANH CHUYỂN TAB
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF3C1C5A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF3C1C5A),
                tabs: [
                  Tab(text: 'VỪA QUA'),
                  Tab(text: 'SẮP TỚI'),
                ],
              ),
            ),

            // NỘI DUNG 2 TAB LỊCH THI ĐẤU
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
                  : TabBarView(
                children: [
                  _buildMatchesList(lastMatches, "Đội bóng chưa đá trận nào gần đây."),
                  _buildMatchesList(nextMatches, "Đội bóng chưa có lịch đá sắp tới."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tái sử dụng để vẽ danh sách trận đấu
  Widget _buildMatchesList(List<MatchEvent> matches, String emptyMessage) {
    if (matches.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return MatchCard(match: matches[index]);
      },
    );
  }
}