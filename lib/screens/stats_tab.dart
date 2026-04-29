import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/top_scorer_model.dart';
import '../services/api_service.dart';
import 'player_profile_screen.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  // Dong nhat kieu du lieu cho ca 2 danh sach
  List<PlayerStats> topScorers = [];
  List<PlayerStats> topAssists = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.fetchTopScorers(),
        _apiService.fetchTopAssists(),
      ]);

      if (mounted) {
        setState(() {
          topScorers = results[0];
          topAssists = results[1];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Loi tai thong ke: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF3C1C5A),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Color(0xFFE90052),
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'VUA PHÁ LƯỚI'),
              Tab(text: 'KIẾN TẠO'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
            : TabBarView(
          children: [
            // TAB 1: VUA PHA LUOI
            _buildStatList(
              statName: 'Bàn thắng',
              itemCount: topScorers.length,
              itemBuilder: (context, index) {
                final player = topScorers[index];
                return _buildPlayerRow(
                  context: context,
                  index: index,
                  playerId: player.playerId,
                  teamId: player.teamId,
                  playerName: player.playerShortName,
                  teamName: player.teamName,
                  statValue: player.goals.toString(),
                );
              },
            ),

            // TAB 2: VUA KIEN TAO
            _buildStatList(
              statName: 'Kiến tạo',
              itemCount: topAssists.length,
              itemBuilder: (context, index) {
                final player = topAssists[index];
                return _buildPlayerRow(
                  context: context,
                  index: index,
                  playerId: player.playerId,
                  teamId: player.teamId,
                  playerName: player.playerShortName,
                  teamName: player.teamName,
                  statValue: player.assists.toString(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatList({required String statName, required int itemCount, required Widget Function(BuildContext, int) itemBuilder}) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF3C1C5A),
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 48),
                const Expanded(child: Text('Cầu thủ', style: TextStyle(fontWeight: FontWeight.bold))),
                Text(statName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: itemCount,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: itemBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required BuildContext context,
    required int index,
    required int playerId,
    required int teamId,
    required String playerName,
    required String teamName,
    required String statValue,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => PlayerProfileScreen(
              playerId: playerId,
              playerName: playerName,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: index < 3 ? const Color(0xFFE90052) : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Hero(
              tag: 'player_$playerId',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'http://10.0.2.2:8080/api/sofascore/player-image/$playerId',
                    httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2:8080/api/sofascore/team-logo/$teamId',
                        httpHeaders: const {"ngrok-skip-browser-warning": "true"},
                        width: 14, height: 14,
                        errorWidget: (context, url, error) => const Icon(Icons.shield, size: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(teamName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Text(
                statValue,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}