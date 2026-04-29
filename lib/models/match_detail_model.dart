// File: lib/models/match_detail_model.dart

// 1. KHUÔN ĐÚC CHO ĐỘI HÌNH (LINEUPS)
class LineupResponse {
  final List<MatchPlayer> homePlayers;
  final List<MatchPlayer> awayPlayers;

  LineupResponse({required this.homePlayers, required this.awayPlayers});

  factory LineupResponse.fromJson(Map<String, dynamic> json) {
    List<MatchPlayer> home = [];
    List<MatchPlayer> away = [];

    // Lấy danh sách cầu thủ đội nhà
    if (json['home'] != null && json['home']['players'] != null) {
      home = (json['home']['players'] as List)
          .map((e) => MatchPlayer.fromJson(e))
          .toList();
      _autoArrangeFormation(home.where((p) => !p.isSubstitute).toList());
    }
    // Lấy danh sách cầu thủ đội khách
    if (json['away'] != null && json['away']['players'] != null) {
      away = (json['away']['players'] as List)
          .map((e) => MatchPlayer.fromJson(e))
          .toList();
      _autoArrangeFormation(away.where((p) => !p.isSubstitute).toList());
    }

    return LineupResponse(homePlayers: home, awayPlayers: away);
  }

  // ✅ BÍ QUYẾT TÍNH TỌA ĐỘ KHI API KHÔNG TRẢ VỀ
  static void _autoArrangeFormation(List<MatchPlayer> players) {
    // 1. Phân loại cầu thủ theo tuyến
    final goalKeepers = players.where((p) => p.position == 'G').toList();
    final defenders = players.where((p) => p.position == 'D').toList();
    final midfielders = players.where((p) => p.position == 'M').toList();
    final forwards = players.where((p) => p.position == 'F').toList();
    final unknowns = players.where((p) => !['G', 'D', 'M', 'F'].contains(p.position)).toList();

    // 2. Gán trục Y (Chiều dọc: 0 là Gôn nhà, 100 là Giữa sân)
    _distributeLine(goalKeepers, 8.0);   // Gôn đứng sát đáy sân
    _distributeLine(defenders, 28.0);    // Hàng hậu vệ
    _distributeLine(midfielders, 55.0);  // Hàng tiền vệ
    _distributeLine(forwards, 85.0);     // Hàng tiền đạo
    _distributeLine(unknowns, 50.0);     // Lỗi vị trí thì cho đứng giữa sân
  }

  // Hàm chia đều khoảng cách các cầu thủ trên cùng 1 hàng ngang
  static void _distributeLine(List<MatchPlayer> line, double yPos) {
    int count = line.length;
    if (count == 0) return;

    // Tính khoảng cách chia đều trên trục X (từ 0 đến 100)
    double step = 100.0 / (count + 1);
    for (int i = 0; i < count; i++) {
      line[i].positionX = step * (i + 1);
      line[i].positionY = yPos;
    }
  }
}

class MatchPlayer {
  final int id;
  final String name;
  final String position;
  final String jerseyNumber;
  final double rating;

  // Xóa chữ 'final' để có thể cập nhật lại tọa độ bằng thuật toán
  double positionX;
  double positionY;

  final bool isSubstitute;

  MatchPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.jerseyNumber,
    required this.rating,
    this.positionX = 50.0,
    this.positionY = 50.0,
    required this.isSubstitute, // ✅ ĐÃ SỬA LỖI: Thêm khai báo bắt buộc ở đây
  });

  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    final playerInfo = json['player'] ?? {};
    final statsInfo = json['statistics'] ?? {};

    return MatchPlayer(
      id: playerInfo['id'] ?? 0,
      name: playerInfo['shortName'] ?? playerInfo['name'] ?? 'Unknown',
      position: playerInfo['position'] ?? json['position'] ?? '-',
      jerseyNumber: playerInfo['jerseyNumber']?.toString() ?? '-',
      rating: (statsInfo['rating'] ?? 0.0).toDouble(),

      // Khởi tạo tọa độ. Nếu API có sẵn X/Y thì lấy, không có thì Thuật toán sẽ tính lại
      positionX: (json['positionX'] ?? playerInfo['positionX'] ?? 50.0).toDouble(),
      positionY: (json['positionY'] ?? playerInfo['positionY'] ?? 50.0).toDouble(),
      isSubstitute: json['substitute'] ?? false,
    );
  }
}

// 2. KHUÔN ĐÚC CHO THỐNG KÊ (STATISTICS)
class MatchStatItem {
  final String name;
  final String homeValue;
  final String awayValue;

  MatchStatItem({
    required this.name,
    required this.homeValue,
    required this.awayValue,
  });

  factory MatchStatItem.fromJson(Map<String, dynamic> json) {
    return MatchStatItem(
      name: json['name'] ?? '',
      homeValue: json['home']?.toString() ?? '0',
      awayValue: json['away']?.toString() ?? '0',
    );
  }
}

class MatchStatisticsResponse {
  final List<MatchStatItem> statItems;

  MatchStatisticsResponse({required this.statItems});

  factory MatchStatisticsResponse.fromJson(Map<String, dynamic> json) {
    List<MatchStatItem> items = [];

    if (json['statistics'] != null && (json['statistics'] as List).isNotEmpty) {
      final allStats = json['statistics'][0];
      if (allStats['groups'] != null && (allStats['groups'] as List).isNotEmpty) {

        // ✅ BÍ QUYẾT Ở ĐÂY: Duyệt qua TẤT CẢ các nhóm thống kê thay vì chỉ lấy [0]
        for (var group in allStats['groups']) {
          if (group['statisticsItems'] != null) {
            items.addAll((group['statisticsItems'] as List)
                .map((e) => MatchStatItem.fromJson(e))
                .toList());
          }
        }

      }
    }
    return MatchStatisticsResponse(statItems: items);
  }
}