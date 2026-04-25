
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../widgets/match_card.dart';
import '../widgets/shimmer_loading.dart';
class FixturesTab extends StatefulWidget {
  const FixturesTab({super.key});

  @override
  State<FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends State<FixturesTab> {
  List<MatchEvent> matches = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService(); // Khởi tạo dịch vụ lấy API

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // Gọi hàm từ ApiService
      final data = await _apiService.fetchPremierLeagueMatches();
      setState(() {
        matches = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Lịch thi đấu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading && matches.isEmpty
          ? const Center(child: MatchShimmerLoading())
          : matches.isEmpty
          ? Center( // Màn hình báo lỗi
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Không thể tải dữ liệu!', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Thử lại'))
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF3C1C5A),
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            // GỌI MATCH CARD RA ĐÂY (Rất gọn gàng!)
            return MatchCard(match: matches[index]);
          },
        ),
      ),
    );
  }
}