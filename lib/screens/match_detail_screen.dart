// File: lib/screens/match_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../models/match_detail_model.dart';
import '../services/api_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final MatchEvent match; // Nhận dữ liệu trận đấu từ màn hình ngoài truyền vào

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
      // Gọi song song 2 API cùng lúc cho nhanh
      final results = await Future.wait([
        _apiService.fetchMatchStatistics(widget.match.id),
        _apiService.fetchMatchLineups(widget.match.id),
      ]);

      setState(() {
        stats = results[0] as List<MatchStatItem>;
        lineups = results[1] as LineupResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeScore = widget.match.homeScore?.display?.toString() ?? '-';
    final awayScore = widget.match.awayScore?.display?.toString() ?? '-';

    return DefaultTabController(
      length: 2, // Số lượng Tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Chi tiết trận đấu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF3C1C5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // KHU VỰC HEADER TỈ SỐ Ở TRÊN CÙNG
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Đội nhà
                  Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://api.sofascore.app/api/v1/team/${widget.match.homeTeam.id}/image',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.homeTeam.shortName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Tỉ số
                  Column(
                    children: [
                      Text(
                        '$homeScore - $awayScore',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        widget.match.status.description,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Đội khách
                  Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://api.sofascore.app/api/v1/team/${widget.match.awayTeam.id}/image',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.awayTeam.shortName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
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
                  Tab(text: 'THỐNG KÊ'),
                  Tab(text: 'ĐỘI HÌNH'),
                ],
              ),
            ),

            // NỘI DUNG 2 TAB
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3C1C5A),
                      ),
                    )
                  : TabBarView(
                      children: [
                        _buildStatsTab(), // Hàm vẽ Tab 1
                        _buildLineupsTab(), // Hàm vẽ Tab 2
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // GIAO DIỆN TAB THỐNG KÊ
  Widget _buildStatsTab() {
    if (stats.isEmpty)
      return const Center(child: Text('Chưa có thống kê cho trận này.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  stat.homeValue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  stat.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: Text(
                  stat.awayValue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // GIAO DIỆN TAB ĐỘI HÌNH
  Widget _buildLineupsTab() {
    if (lineups == null || lineups!.homePlayers.isEmpty)
      return const Center(child: Text('Chưa có đội hình ra sân.'));

    // Chia màn hình làm 2 cột
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột Đội Nhà
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: lineups!.homePlayers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final player = lineups!.homePlayers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    player.jerseyNumber,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(player.position),
                trailing: Text(
                  player.rating > 0 ? player.rating.toString() : '-',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
        // Vạch kẻ giữa 2 đội
        Container(width: 1, color: Colors.grey[300]),
        // Cột Đội Khách
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: lineups!.awayPlayers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final player = lineups!.awayPlayers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Text(
                    player.jerseyNumber,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(player.position),
                trailing: Text(
                  player.rating > 0 ? player.rating.toString() : '-',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }
}
