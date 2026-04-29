// File: lib/widgets/lineups_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_detail_model.dart';
import '../screens/player_profile_screen.dart';
import 'pitch_view_widget.dart'; // ✅ NHỚ IMPORT FILE SÂN CỎ BẠN VỪA TẠO VÀO ĐÂY

class LineupsTabWidget extends StatefulWidget {
  final LineupResponse? lineups;

  const LineupsTabWidget({super.key, required this.lineups});

  @override
  State<LineupsTabWidget> createState() => _LineupsTabWidgetState();
}

// Chuyển sang StatefulWidget để có thể bấm nút chuyển qua lại 2 chế độ
class _LineupsTabWidgetState extends State<LineupsTabWidget> {
  // Biến kiểm soát đang ở chế độ nào (Mặc định mở lên cho xem Sân cỏ cho ngầu)
  bool isPitchView = true;

  @override
  Widget build(BuildContext context) {
    // ✅ GIAO DIỆN BÁO LỖI CHUYÊN NGHIỆP (Khắc phục triệt để lỗi trận đấu rỗng)
    if (widget.lineups == null || widget.lineups!.homePlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Chưa có dữ liệu đội hình',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trận đấu này hiện chưa được cập nhật\nsơ đồ chiến thuật từ hệ thống.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ================= THANH CHUYỂN ĐỔI (TOGGLE) =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Nút Sân Cỏ
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isPitchView = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPitchView ? const Color(0xFF3C1C5A) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isPitchView ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SÂN CỎ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isPitchView ? Colors.white : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                // Nút Danh Sách
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isPitchView = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isPitchView ? const Color(0xFF3C1C5A) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: !isPitchView ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'DANH SÁCH',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: !isPitchView ? Colors.white : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ================= KHU VỰC HIỂN THỊ CHÍNH =================
        Expanded(
          child: isPitchView
              ? PitchViewWidget(lineups: widget.lineups) // Gọi file Sân cỏ 2D
              : _buildListView(), // Gọi hàm tạo Danh sách truyền thống
        ),
      ],
    );
  }

  // ✅ HÀM TẠO GIAO DIỆN DANH SÁCH (Giữ nguyên code cũ của bạn)
  Widget _buildListView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= ĐỘI NHÀ =================
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.lineups!.homePlayers.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) {
              return _buildPlayerRow(context, widget.lineups!.homePlayers[index], isHome: true);
            },
          ),
        ),

        Container(width: 1, color: Colors.grey[300]), // Vạch kẻ giữa

        // ================= ĐỘI KHÁCH =================
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.lineups!.awayPlayers.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) {
              return _buildPlayerRow(context, widget.lineups!.awayPlayers[index], isHome: false);
            },
          ),
        ),
      ],
    );
  }

  // ✅ HÀM TẠO TỪNG DÒNG CẦU THỦ (Giữ nguyên code gắn Hero)
  Widget _buildPlayerRow(BuildContext context, dynamic player, {required bool isHome}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => PlayerProfileScreen(
              playerId: player.id,
              playerName: player.name,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                player.jerseyNumber,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHome ? Colors.blue[700] : Colors.red[700]
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            Hero(
              tag: 'player_${player.id}',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'http://10.0.2.2:8080/api/sofascore/player-image/${player.id}',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                      _getPositionName(player.position),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)
                  ),
                ],
              ),
            ),
            if (player.rating > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: player.rating >= 7.5 ? Colors.green[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  player.rating.toString(),
                  style: TextStyle(
                      color: player.rating >= 7.5 ? Colors.green[800] : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                  ),
                ),
              )
            else
              const Text('-', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _getPositionName(String? code) {
    switch (code) {
      case 'G': return 'Thủ môn';
      case 'D': return 'Hậu vệ';
      case 'M': return 'Tiền vệ';
      case 'F': return 'Tiền đạo';
      default: return 'Cầu thủ';
    }
  }
}