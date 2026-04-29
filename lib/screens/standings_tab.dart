// File: lib/screens/standings_tab.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/standing_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart'; // Để check đăng nhập
import 'team_profile_screen.dart';

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  List<StandingRow> standings = [];
  Set<int> followedTeamIds = {}; // Bộ lọc ID các đội đã follow
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu Bảng xếp hạng và Danh sách Follow cùng lúc
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      List<Future> tasks = [_apiService.fetchStandings()];

      if (UserSession.mySqlUserId != null) {
        tasks.add(_apiService.getFollowedTeams(UserSession.mySqlUserId!));
      }

      final results = await Future.wait(tasks);

      setState(() {
        standings = results[0] as List<StandingRow>;

        if (results.length > 1) {
          final List<dynamic> followedData = results[1];
          followedTeamIds = followedData.map((t) => int.parse(t['apiId'].toString())).toSet();
        }

        isLoading = false;
      });
    } catch (e) {
      print("Lỗi tải BXH: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
          : RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF3C1C5A),
        child: Column(
          children: [
            // TIÊU ĐỀ CỘT
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: const Row(
                children: [
                  SizedBox(width: 35, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 35),
                  Expanded(child: Text('Đội', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('Tr', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('Đ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // DANH SÁCH ĐỘI BÓNG
            Expanded(
              child: ListView.separated(
                itemCount: standings.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = standings[index];

                  // KIỂM TRA ĐỘI NÀY CÓ ĐƯỢC FOLLOW KHÔNG
                  final isFollowed = followedTeamIds.contains(row.team.id);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamProfileScreen(
                            teamId: row.team.id,
                            teamName: row.team.shortName,
                            // SỬA 1: Dùng link proxy qua Spring Boot cho Navigator
                            logoUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${row.team.id}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: isFollowed ? Colors.yellow.withOpacity(0.15) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 35,
                            child: Row(
                              children: [
                                Text('${row.position}',
                                    style: TextStyle(
                                        fontWeight: isFollowed ? FontWeight.w900 : FontWeight.bold,
                                        color: isFollowed ? const Color(0xFFE90052) : Colors.black
                                    )
                                ),
                                if (isFollowed) const Icon(Icons.star, color: Colors.amber, size: 10),
                              ],
                            ),
                          ),
                          // SỬA 2: Dùng link proxy qua Spring Boot cho Logo hiển thị
                          CachedNetworkImage(
                            imageUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/${row.team.id}',
                            width: 25, height: 25,
                            errorWidget: (context, url, error) => const Icon(Icons.shield, size: 25),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Text(
                                  row.team.shortName,
                                  style: TextStyle(
                                      fontWeight: isFollowed ? FontWeight.bold : FontWeight.w500,
                                      color: isFollowed ? const Color(0xFF3C1C5A) : Colors.black
                                  )
                              )
                          ),
                          SizedBox(width: 30, child: Text('${row.matches}', textAlign: TextAlign.center)),
                          SizedBox(width: 30, child: Text('${row.wins}', textAlign: TextAlign.center)),
                          SizedBox(
                              width: 30,
                              child: Text('${row.points}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                              )
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}