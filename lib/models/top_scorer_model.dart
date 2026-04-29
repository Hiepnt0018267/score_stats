// File: lib/models/top_scorer_model.dart

class PlayerStats {
  final int goals;
  final int assists;
  final int playerId;
  final String playerName;
  final String playerShortName;
  final int teamId;
  final String teamName;

  PlayerStats({
    required this.goals,
    required this.assists,
    required this.playerId,
    required this.playerName,
    required this.playerShortName,
    required this.teamId,
    required this.teamName,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    // 🕵️ CHIẾN THUẬT DÒ TÌM THÔNG MINH (SMART PARSING)
    // Bước 1: Xác định nguồn dữ liệu thống kê (Ưu tiên lấy trực tiếp từ json nếu không có statistics)
    final dynamic stats = json['statistics'] ?? json;

    // Bước 2: Xác định nguồn dữ liệu Player & Team (SofaScore có khi để team trong player, có khi để ngoài)
    final player = json['player'] ?? {};
    final team = json['team'] ?? player['team'] ?? {};

    // Bước 3: Ép kiểu dữ liệu an toàn (Dùng int.tryParse để chống lỗi kiểu dữ liệu)
    int parseStat(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return PlayerStats(
      // Tìm 'goals' hoặc 'score'
      goals: parseStat(stats['goals'] ?? stats['score']),

      // Tìm 'assists'
      assists: parseStat(stats['assists']),

      playerId: player['id'] ?? 0,
      playerName: player['name'] ?? 'Unknown',
      playerShortName: player['shortName'] ?? player['name'] ?? 'Unknown',

      teamId: team['id'] ?? 0,
      teamName: team['name'] ?? 'Unknown',
    );
  }
}