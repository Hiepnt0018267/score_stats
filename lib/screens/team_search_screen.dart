// File: lib/screens/team_search_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'team_profile_screen.dart';
import 'dart:async';

class TeamSearchScreen extends StatefulWidget {
  const TeamSearchScreen({super.key});

  @override
  State<TeamSearchScreen> createState() => _TeamSearchScreenState();
}

class _TeamSearchScreenState extends State<TeamSearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<dynamic> searchResults = [];
  Set<int> _followedTeamIds = {};
  Set<int> _loadingTeamIds = {}; // Quản lý hiệu ứng loading cho từng nút

  bool isLoading = false;
  bool hasSearched = false;
  Timer? _debounce;

  // Tự động chọn link ảnh chuẩn dựa trên môi trường (Máy ảo hay Điện thoại thật)
  final String _imageHost = ApiService.isProduction
      ? 'https://untreated-countdown-repulsive.ngrok-free.dev'
      : 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _loadFollowedTeams();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> _loadFollowedTeams() async {
    if (UserSession.mySqlUserId != null) {
      final teams = await _apiService.getFollowedTeams(UserSession.mySqlUserId!);
      if (mounted) {
        setState(() {
          _followedTeamIds = teams.map((t) => int.parse(t['apiId'].toString())).toSet();
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _handleSearch(query);
      } else {
        setState(() {
          searchResults.clear();
          hasSearched = false;
        });
      }
    });
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final results = await _apiService.searchTeams(query);

    if (mounted) {
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    }
  }

  Future<void> toggleFollow(int apiTeamId, String teamName, String logoUrl) async {
    if (UserSession.mySqlUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để ghim đội bóng!'), backgroundColor: Colors.red)
      );
      return;
    }

    // Bật hiệu ứng loading cho nút vừa bấm
    setState(() => _loadingTeamIds.add(apiTeamId));

    bool isCurrentlyFollowed = _followedTeamIds.contains(apiTeamId);
    bool success = false;

    if (isCurrentlyFollowed) {
      // HỦY FOLLOW
      success = await _apiService.unfollowTeam(UserSession.mySqlUserId!, apiTeamId);
      if (success && mounted) {
        setState(() => _followedTeamIds.remove(apiTeamId));
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bỏ theo dõi')));
      }
    } else {
      // THÊM FOLLOW
      success = await _apiService.followTeam(UserSession.mySqlUserId!, apiTeamId, teamName, logoUrl);
      if (success && mounted) {
        setState(() => _followedTeamIds.add(apiTeamId));
        UserSession.triggerFollowUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đã ghim $teamName'), backgroundColor: Colors.green)
        );
      }
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi máy chủ, vui lòng thử lại!'), backgroundColor: Colors.red)
      );
    }

    // Tắt hiệu ứng loading
    if (mounted) {
      setState(() => _loadingTeamIds.remove(apiTeamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              hintText: 'Nhập tên đội bóng...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none
          ),
          onChanged: _onSearchChanged,
        ),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchResults.clear();
                hasSearched = false;
                _focusNode.requestFocus();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
          : hasSearched && searchResults.isEmpty
          ? const Center(child: Text('Không tìm thấy đội bóng nào 😢'))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final team = searchResults[index];
          final apiId = team['id'];
          final teamName = team['name'];

          // Link proxy lấy ảnh ĐỘNG
          final logoUrl = '$_imageHost/api/sofascore/team-logo/$apiId';

          bool isFollowed = _followedTeamIds.contains(apiId);
          bool isBtnLoading = _loadingTeamIds.contains(apiId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: logoUrl,
                httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                width: 40, height: 40,
                errorWidget: (context, url, error) => const Icon(Icons.shield, color: Colors.grey),
              ),
              title: Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),

              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowed ? Colors.grey[300] : const Color(0xFFE90052),
                  foregroundColor: isFollowed ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: isFollowed ? 0 : 2,
                  minimumSize: const Size(110, 36),
                ),
                onPressed: isBtnLoading ? null : () => toggleFollow(apiId, teamName, logoUrl),
                child: isBtnLoading
                    ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isFollowed ? Icons.check : Icons.favorite_border, size: 16),
                    const SizedBox(width: 4),
                    Text(isFollowed ? 'Đã Follow' : 'Follow'),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TeamProfileScreen(
                        teamId: apiId,
                        teamName: teamName,
                        logoUrl: logoUrl
                    )
                )).then((_) {
                  // Tự động load lại trạng thái nút bấm khi quay về từ trang hồ sơ
                  _loadFollowedTeams();
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}