import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/standing_model.dart';
import '../services/api_service.dart';

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  List<StandingRow> standings = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  Future<void> _loadStandings() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.fetchStandings();
      setState(() {
        standings = data;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi tại Tab 2: $e");
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
        onRefresh: _loadStandings,
        color: const Color(0xFF3C1C5A),
        child: Column(
          children: [
            // TIÊU ĐỀ CỘT
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: const Row(
                children: [
                  SizedBox(width: 25, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 40),
                  Expanded(child: Text('Đội', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('Tr', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 30, child: Text('Đ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))), // Điểm
                ],
              ),
            ),
            // DANH SÁCH
            Expanded(
              child: ListView.separated(
                itemCount: standings.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = standings[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 25, child: Text('${row.position}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        CachedNetworkImage(
                          imageUrl: 'https://api.sofascore.app/api/v1/team/${row.team.id}/image',
                          width: 25, height: 25,
                          errorWidget: (context, url, error) => const Icon(Icons.shield, size: 25),
                        ),
                        const SizedBox(width: 15),
                        Expanded(child: Text(row.team.shortName, style: const TextStyle(fontWeight: FontWeight.w500))),
                        SizedBox(width: 30, child: Text('${row.matches}', textAlign: TextAlign.center)),
                        SizedBox(width: 30, child: Text('${row.wins}', textAlign: TextAlign.center)),
                        SizedBox(width: 30, child: Text('${row.points}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
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