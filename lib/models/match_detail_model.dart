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
      home = (json['home']['players'] as List).map((e) => MatchPlayer.fromJson(e)).toList();
    }
    // Lấy danh sách cầu thủ đội khách
    if (json['away'] != null && json['away']['players'] != null) {
      away = (json['away']['players'] as List).map((e) => MatchPlayer.fromJson(e)).toList();
    }

    return LineupResponse(homePlayers: home, awayPlayers: away);
  }
}

class MatchPlayer {
  final String name;
  final String position;
  final String jerseyNumber;
  final double rating;

  MatchPlayer({required this.name, required this.position, required this.jerseyNumber, required this.rating});

  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    final playerInfo = json['player'] ?? {};
    final statsInfo = json['statistics'] ?? {};

    return MatchPlayer(
      name: playerInfo['shortName'] ?? playerInfo['name'] ?? 'Unknown',
      position: playerInfo['position'] ?? '-',
      jerseyNumber: playerInfo['jerseyNumber']?.toString() ?? '-',
      // Ép kiểu an toàn cho rating (vì có thể là double hoặc int)
      rating: (statsInfo['rating'] ?? 0.0).toDouble(),
    );
  }
}

// 2. KHUÔN ĐÚC CHO THỐNG KÊ (STATISTICS)
class MatchStatItem {
  final String name;      // VD: "Ball possession"
  final String homeValue; // VD: "68%"
  final String awayValue; // VD: "32%"

  MatchStatItem({required this.name, required this.homeValue, required this.awayValue});

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

    // Bóc tách JSON phức tạp nhiều lớp của Sofascore
    if (json['statistics'] != null && (json['statistics'] as List).isNotEmpty) {
      final allStats = json['statistics'][0]; // Lấy period: "ALL"
      if (allStats['groups'] != null && (allStats['groups'] as List).isNotEmpty) {

        // Lấy nhóm "Match overview" (thường nằm ở index 0)
        final overviewGroup = allStats['groups'][0];
        if (overviewGroup['statisticsItems'] != null) {
          items = (overviewGroup['statisticsItems'] as List)
              .map((e) => MatchStatItem.fromJson(e))
              .toList();
        }
      }
    }
    return MatchStatisticsResponse(statItems: items);
  }
}