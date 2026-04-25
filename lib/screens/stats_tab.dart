// File: lib/screens/stats_tab.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/top_scorer_model.dart';
import '../services/api_service.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<PlayerStats> topScorers = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTopScorers();
  }

  Future<void> _loadTopScorers() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.fetchTopScorers();
      setState(() {
        topScorers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Vua phá lưới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3C1C5A)),
            )
          : RefreshIndicator(
              onRefresh: _loadTopScorers,
              color: const Color(0xFF3C1C5A),
              child: Column(
                children: [
                  // TIÊU ĐỀ
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '#',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 40), // Cột Logo
                        Expanded(
                          child: Text(
                            'Cầu thủ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Bàn thắng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // DANH SÁCH CẦU THỦ
                  Expanded(
                    child: ListView.separated(
                      itemCount: topScorers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final player = topScorers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              // Hạng (In đậm top 3)
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: index < 3
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // Logo Đội bóng
                              CachedNetworkImage(
                                imageUrl:
                                    'https://api.sofascore.app/api/v1/team/${player.teamId}/image',
                                width: 30,
                                height: 30,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.shield,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              // Tên Cầu thủ & Đội bóng
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.playerShortName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      player.teamName,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bàn thắng (Nổi bật)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${player.goals}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
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
