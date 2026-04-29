// File: lib/widgets/pitch_view_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_detail_model.dart';
import '../screens/player_profile_screen.dart';

class PitchViewWidget extends StatelessWidget {
  final LineupResponse? lineups;

  const PitchViewWidget({super.key, required this.lineups});

  @override
  Widget build(BuildContext context) {
    if (lineups == null || lineups!.homePlayers.isEmpty) {
      return const Center(child: Text('Chưa có sơ đồ chiến thuật.'));
    }

    // Lấy chiều rộng màn hình để tính toán tỷ lệ sân bóng
    final double screenWidth = MediaQuery.of(context).size.width;
    // Chiều dài sân tỷ lệ vàng (thường là rộng x 1.5 hoặc 1.6)
    final double pitchHeight = screenWidth * 1.5;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: screenWidth,
          height: pitchHeight,
          // NỀN SÂN CỎ
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50), // Xanh lá
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --- CÁC VẠCH KẺ SÂN ---
              // Vạch giữa sân
              Positioned(
                top: pitchHeight / 2, left: 0, right: 0,
                child: Container(height: 2, color: Colors.white.withOpacity(0.5)),
              ),
              // Vòng tròn giữa sân
              Positioned(
                top: (pitchHeight / 2) - 40, left: (screenWidth / 2) - 40,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
                ),
              ),

              // --- ĐỘI NHÀ (Chỉ lấy 11 người đá chính) ---
              ...lineups!.homePlayers
                  .where((p) => !p.isSubstitute) // ✅ Lọc dự bị đội nhà
                  .map((player) => _buildPlayerDot(
                context: context,
                player: player,
                pitchWidth: screenWidth,
                pitchHeight: pitchHeight,
                isHome: true,
              )).toList(),

              // --- ĐỘI KHÁCH (Chỉ lấy 11 người đá chính) ---
              ...lineups!.awayPlayers
                  .where((p) => !p.isSubstitute) // ✅ ĐÃ BỔ SUNG: Lọc dự bị đội khách
                  .map((player) => _buildPlayerDot(
                context: context,
                player: player,
                pitchWidth: screenWidth,
                pitchHeight: pitchHeight,
                isHome: false,
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ HÀM VẼ CHẤM CẦU THỦ
  Widget _buildPlayerDot({
    required BuildContext context,
    required dynamic player,
    required double pitchWidth,
    required double pitchHeight,
    required bool isHome,
  }) {
    // 1. TÍNH TOÁN TỌA ĐỘ THEO PHẦN TRĂM
    double percentX = player.positionX / 100.0;
    double percentY = player.positionY / 100.0;

    double realY;
    if (isHome) {
      // Đội nhà: Tấn công từ dưới lên
      realY = pitchHeight - (percentY * (pitchHeight / 2));
    } else {
      // Đội khách: Tấn công từ trên xuống
      realY = percentY * (pitchHeight / 2);
    }

    // 2. VẼ CHẤM TRÒN
    return Positioned(
      left: (percentX * pitchWidth) - 20,
      top: realY - 20,
      child: GestureDetector(
        onTap: () {
          // HIỆU ỨNG BAY 2 CHIỀU
          Navigator.push(context, PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => PlayerProfileScreen(playerId: player.id, playerName: player.name),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ));
        },
        child: Column(
          children: [
            // CHẤM TRÒN SỐ ÁO
            Hero(
              tag: 'player_${player.id}',
              child: Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Đổi màu tùy ý theo đội nhà/khách
                  color: isHome ? Colors.blue[700] : Colors.red[700],
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Text(
                  player.jerseyNumber.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none),
                ),
              ),
            ),
            // TÊN CẦU THỦ NẰM DƯỚI
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
              child: Text(
                _getShortName(player.name),
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortName(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length > 1) {
      return parts.last;
    }
    return fullName;
  }
}