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

  // Mỏ neo giữ bàn phím không bị mất Focus
  final FocusNode _focusNode = FocusNode();

  List<dynamic> searchResults = [];
  Set<int> _followedTeamIds = {}; // Danh sách ID các đội đã ghim
  bool isLoading = false;
  bool hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadFollowedTeams();

    // Bật bàn phím an toàn sau khi màn hình dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  // Hàm kéo danh sách đội đã follow từ Spring Boot
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

  // Hàm xử lý cả Follow và Unfollow
  Future<void> toggleFollow(int apiTeamId, String teamName) async {
    if (UserSession.mySqlUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập!'), backgroundColor: Colors.red)
      );
      return;
    }

    bool isCurrentlyFollowed = _followedTeamIds.contains(apiTeamId);

    if (isCurrentlyFollowed) {
      // 1. UNFOLLOW
      bool success = await _apiService.unfollowTeam(UserSession.mySqlUserId!, apiTeamId);
      if (success && mounted) {
        setState(() => _followedTeamIds.remove(apiTeamId));
        UserSession.triggerFollowUpdate(); // Rung chuông báo thay đổi
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã bỏ theo dõi $teamName'))
        );
      }
    } else {
      // 2. FOLLOW
      String logoUrl = 'http://10.0.2.2:8080/api/sofascore/team-logo/$apiTeamId';
      bool success = await _apiService.followTeam(UserSession.mySqlUserId!, apiTeamId, teamName, logoUrl);
      if (success && mounted) {
        setState(() => _followedTeamIds.add(apiTeamId));
        UserSession.triggerFollowUpdate(); // Rung chuông báo thay đổi
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đã ghim $teamName'), backgroundColor: Colors.green)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode, // Gắn mỏ neo
          autofocus: false,
          textInputAction: TextInputAction.search, // Nút tìm kiếm dưới bàn phím
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
                _focusNode.requestFocus(); // Nhấn xóa xong giữ nguyên bàn phím
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

          // Link proxy lấy ảnh
          final logoUrl = 'http://10.0.2.2:8080/api/sofascore/team-logo/$apiId';

          // Kiểm tra trạng thái Follow
          bool isFollowed = _followedTeamIds.contains(apiId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CachedNetworkImage(
                imageUrl: logoUrl,
                width: 40, height: 40,
                errorWidget: (context, url, error) => const Icon(Icons.shield, color: Colors.grey),
              ),
              title: Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),

              // NÚT FOLLOW THÔNG MINH
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowed ? Colors.grey[300] : const Color(0xFFE90052),
                  foregroundColor: isFollowed ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: isFollowed ? 0 : 2,
                ),
                icon: Icon(isFollowed ? Icons.check : Icons.favorite_border, size: 16),
                label: Text(isFollowed ? 'Đã Follow' : 'Follow'),
                onPressed: () => toggleFollow(apiId, teamName),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TeamProfileScreen(
                        teamId: apiId,
                        teamName: teamName,
                        logoUrl: logoUrl
                    )
                ));
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Hủy mỏ neo
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}