// File: lib/screens/player_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  final int playerId;
  final String playerName;

  const PlayerProfileScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  Map<String, dynamic>? playerInfo;

  // Màu mặc định: Tím Ngoại Hạng Anh
  Color _themeColor = const Color(0xFF3C1C5A);

  @override
  void initState() {
    super.initState();
    _loadPlayerInfo();
  }

  Future<void> _loadPlayerInfo() async {
    final info = await _apiService.fetchPlayerInfo(widget.playerId);
    if (mounted) {
      setState(() {
        playerInfo = info;
        isLoading = false;

        // Ngay khi có tên đội bóng, tra từ điển màu sắc và đổi màu LẬP TỨC!
        if (info != null && info['team'] != null) {
          _themeColor = _getTeamColor(info['team']['name']);
        }
      });
    }
  }

  // ✅ BÍ QUYẾT: TỪ ĐIỂN MÀU SẮC CHUẨN CỦA CLB NGOẠI HẠNG ANH
  Color _getTeamColor(String teamName) {
    String name = teamName.toLowerCase();

    if (name.contains('arsenal')) return const Color(0xFFEF0107); // Đỏ Arsenal
    if (name.contains('manchester city')) return const Color(0xFF6CABDD); // Xanh Man City
    if (name.contains('manchester united')) return const Color(0xFFDA291C); // Đỏ MU
    if (name.contains('liverpool')) return const Color(0xFFC8102E); // Đỏ Liverpool
    if (name.contains('chelsea')) return const Color(0xFF034694); // Xanh Chelsea
    if (name.contains('tottenham')) return const Color(0xFF132257); // Xanh đen Tottenham
    if (name.contains('aston villa')) return const Color(0xFF7A263A); // Đỏ bã trầu Villa
    if (name.contains('newcastle')) return const Color(0xFF241F20); // Đen Newcastle
    if (name.contains('brighton')) return const Color(0xFF0057B8); // Xanh dương Brighton
    if (name.contains('west ham')) return const Color(0xFF7A263A); // Đỏ bã trầu West Ham
    if (name.contains('everton')) return const Color(0xFF003399); // Xanh Everton
    if (name.contains('wolves') || name.contains('wolverhampton')) return const Color(0xFFFDB913); // Vàng Wolves
    if (name.contains('brentford')) return const Color(0xFFE30613); // Đỏ Brentford
    if (name.contains('nottingham')) return const Color(0xFFE53233); // Đỏ Nottingham
    if (name.contains('crystal palace')) return const Color(0xFF1B458F); // Xanh đỏ Palace
    if (name.contains('fulham')) return const Color(0xFF111111); // Đen Fulham

    // Nếu không khớp (Cầu thủ chuyển nhượng, đội xuống hạng...), trả về Tím mặc định
    return const Color(0xFF3C1C5A);
  }

  String getPositionName(String? code) {
    switch (code) {
      case 'G': return 'Thủ môn';
      case 'D': return 'Hậu vệ';
      case 'M': return 'Tiền vệ';
      case 'F': return 'Tiền đạo';
      default: return 'Cầu thủ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String photoUrl = 'http://10.0.2.2:8080/api/sofascore/player-image/${widget.playerId}';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            // Thanh AppBar cuộn lên cũng đổi màu mượt mà theo
            backgroundColor: _themeColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                playerInfo?['name'] ?? widget.playerName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, shadows: [Shadow(color: Colors.black87, blurRadius: 2)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ ANIMATED CONTAINER SIÊU MƯỢT
                  // 600ms + Curves.easeInOut tạo cảm giác màu sắc từ từ "ngấm" ra màn hình
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    color: _themeColor,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Hero(
                        tag: 'player_${widget.playerId}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: photoUrl,
                                width: 130, height: 130, fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Icon(Icons.person, size: 80, color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (playerInfo != null) ...[
                            const Icon(Icons.shield, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(playerInfo!['team']?['name'] ?? 'Tự do', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Text(playerInfo!['country']?['name'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          ]
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _themeColor)),
            )
          else if (playerInfo == null)
            const SliverFillRemaining(
              child: Center(child: Text('Không thể tải dữ liệu cầu thủ 😢')),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THÔNG TIN CHI TIẾT', style: TextStyle(fontWeight: FontWeight.bold, color: _themeColor.withOpacity(0.8), fontSize: 13)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.sports_soccer, 'Vị trí', getPositionName(playerInfo!['position'])),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.numbers, 'Số áo', playerInfo!['shirtNumber']?.toString() ?? 'N/A'),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.height, 'Chiều cao', playerInfo!['height'] != null ? "${playerInfo!['height']} cm" : 'N/A'),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.settings_accessibility, 'Chân thuận', playerInfo!['preferredFoot'] == 'Left' ? 'Chân trái' : (playerInfo!['preferredFoot'] == 'Right' ? 'Chân phải' : 'Cả hai chân')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 400),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _themeColor.withOpacity(0.6)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}