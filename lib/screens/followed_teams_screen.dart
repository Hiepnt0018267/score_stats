// File: lib/screens/followed_teams_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'team_profile_screen.dart';

class FollowedTeamsScreen extends StatefulWidget {
  const FollowedTeamsScreen({super.key});

  @override
  State<FollowedTeamsScreen> createState() => _FollowedTeamsScreenState();
}

class _FollowedTeamsScreenState extends State<FollowedTeamsScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<dynamic> followedTeams = [];

  // 1. CHỐT LINK ẢNH ĐỘNG (Tránh lỗi ảnh khi chạy 4G)
  final String _imageHost = ApiService.isProduction
      ? 'https://untreated-countdown-repulsive.ngrok-free.dev' // Link Ngrok hiện tại
      : 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    if (UserSession.mySqlUserId == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final teams = await _apiService.getFollowedTeams(UserSession.mySqlUserId!);
    if (mounted) {
      setState(() {
        followedTeams = teams;
        isLoading = false;
      });
    }
  }

  Future<void> _handleUnfollow(int apiId, String teamName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ theo dõi?'),
        content: Text('Bạn có chắc muốn bỏ theo dõi $teamName không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Đồng ý', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⏳ Đang xóa...')));

      bool success = await _apiService.unfollowTeam(UserSession.mySqlUserId!, apiId);

      if (success && mounted) {
        _loadTeams(); // Load lại danh sách sau khi xóa
        UserSession.triggerFollowUpdate(); // Báo cho các màn hình khác biết
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Đã bỏ theo dõi!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Lỗi: Không thể xóa!'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội bóng yêu thích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
          : UserSession.mySqlUserId == null
          ? const Center(child: Text('Vui lòng đăng nhập để xem danh sách!', style: TextStyle(fontSize: 16)))
          : followedTeams.isEmpty
          ? const Center(child: Text('Bạn chưa theo dõi đội bóng nào ⚽', style: TextStyle(fontSize: 16)))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: followedTeams.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final team = followedTeams[index];
          final apiId = int.parse(team['apiId'].toString());

          // Tạo link ảnh an toàn dựa trên môi trường (bỏ qua cái lưu trong MySQL)
          final safeLogoUrl = '$_imageHost/api/sofascore/team-logo/$apiId';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            leading: CachedNetworkImage(
              imageUrl: safeLogoUrl,
              width: 50,
              height: 50,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.sports_soccer),
            ),
            title: Text(team['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                _handleUnfollow(apiId, team['name']);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamProfileScreen(
                    teamId: apiId,
                    teamName: team['name'],
                    logoUrl: safeLogoUrl,
                  ),
                ),
              ).then((_) {
                // 2. LÀM MỚI DANH SÁCH: Khi ấn Back từ trang Profile, tự động tải lại
                _loadTeams();
              });
            },
          );
        },
      ),
    );
  }
}