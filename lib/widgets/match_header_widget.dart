// File: lib/widgets/match_header_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../screens/team_profile_screen.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class MatchHeaderWidget extends StatefulWidget {
  final MatchEvent match;
  final Function? onFollow;

  const MatchHeaderWidget({
    super.key,
    required this.match,
    this.onFollow,
  });

  @override
  State<MatchHeaderWidget> createState() => _MatchHeaderWidgetState();
}

class _MatchHeaderWidgetState extends State<MatchHeaderWidget> {
  final ApiService _apiService = ApiService();
  bool isHomeFollowed = false;
  bool isAwayFollowed = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (UserSession.mySqlUserId != null) {
      final teams = await _apiService.getFollowedTeams(UserSession.mySqlUserId!);
      final followedIds = teams.map((t) => int.parse(t['apiId'].toString())).toSet();

      if (mounted) {
        setState(() {
          isHomeFollowed = followedIds.contains(widget.match.homeTeam.id);
          isAwayFollowed = followedIds.contains(widget.match.awayTeam.id);
        });
      }
    }
  }

  // ✅ HÀM TOGGLE ĐÃ ĐƯỢC CHỮA BỆNH
  Future<void> _toggleFollow(int teamId, String teamName, bool isHomeTeam) async {
    // 1. NẾU CHƯA ĐĂNG NHẬP: Chuyền bóng cho file cha (MatchDetailScreen) xử lý để nhảy Tab
    if (UserSession.mySqlUserId == null) {
      if (widget.onFollow != null) {
        String logoUrl = 'http://10.0.2.2:8080/api/sofascore/team-logo/$teamId';
        widget.onFollow!(0, teamId, teamName, logoUrl);
      }
      return; // Dừng luôn tại đây, không làm gì thêm ở file này
    }

    // 2. NẾU ĐÃ ĐĂNG NHẬP: Tự xử lý đổi màu tim tại chỗ
    bool currentlyFollowed = isHomeTeam ? isHomeFollowed : isAwayFollowed;

    if (currentlyFollowed) {
      // Unfollow
      bool success = await _apiService.unfollowTeam(UserSession.mySqlUserId!, teamId);
      if (success && mounted) {
        setState(() {
          if (isHomeTeam) isHomeFollowed = false;
          else isAwayFollowed = false;
        });
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã bỏ ghim $teamName')));
      }
    } else {
      // Follow
      String logoUrl = 'http://10.0.2.2:8080/api/sofascore/team-logo/$teamId';
      bool success = await _apiService.followTeam(UserSession.mySqlUserId!, teamId, teamName, logoUrl);
      if (success && mounted) {
        setState(() {
          if (isHomeTeam) isHomeFollowed = true;
          else isAwayFollowed = true;
        });
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã ghim $teamName'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeScore = widget.match.homeScore?.display?.toString() ?? '-';
    final awayScore = widget.match.awayScore?.display?.toString() ?? '-';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ================= ĐỘI NHÀ =================
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TeamProfileScreen(
                teamId: widget.match.homeTeam.id,
                teamName: widget.match.homeTeam.shortName,
                logoUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${widget.match.homeTeam.id}',
              )));
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${widget.match.homeTeam.id}',
                  httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                  width: 60, height: 60,
                  errorWidget: (context, url, error) => const Icon(Icons.shield, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(widget.match.homeTeam.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 30,
                  child: TextButton.icon(
                    onPressed: () => _toggleFollow(widget.match.homeTeam.id, widget.match.homeTeam.shortName, true),
                    icon: Icon(isHomeFollowed ? Icons.favorite : Icons.favorite_border, size: 14, color: isHomeFollowed ? const Color(0xFFE90052) : Colors.grey),
                    label: Text(isHomeFollowed ? 'Đã ghim' : 'Follow', style: TextStyle(fontSize: 12, color: isHomeFollowed ? const Color(0xFFE90052) : Colors.grey)),
                  ),
                ),
              ],
            ),
          ),

          // ================= TỈ SỐ =================
          Column(
            children: [
              Text('$homeScore - $awayScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              Text(widget.match.status.description, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),

          // ================= ĐỘI KHÁCH =================
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TeamProfileScreen(
                teamId: widget.match.awayTeam.id,
                teamName: widget.match.awayTeam.shortName,
                logoUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${widget.match.awayTeam.id}',
              )));
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${widget.match.awayTeam.id}',
                  httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                  width: 60, height: 60,
                  errorWidget: (context, url, error) => const Icon(Icons.shield, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(widget.match.awayTeam.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 30,
                  child: TextButton.icon(
                    onPressed: () => _toggleFollow(widget.match.awayTeam.id, widget.match.awayTeam.shortName, false),
                    icon: Icon(isAwayFollowed ? Icons.favorite : Icons.favorite_border, size: 14, color: isAwayFollowed ? const Color(0xFFE90052) : Colors.grey),
                    label: Text(isAwayFollowed ? 'Đã ghim' : 'Follow', style: TextStyle(fontSize: 12, color: isAwayFollowed ? const Color(0xFFE90052) : Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}