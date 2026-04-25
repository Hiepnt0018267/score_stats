// File: lib/models/top_scorer_model.dart
class TopScorerResponse {
  final List<PlayerStats> goals;

  TopScorerResponse({required this.goals});

  factory TopScorerResponse.fromJson(Map<String, dynamic> json) {
    if (json['topPlayers'] != null && json['topPlayers']['goals'] != null) {
      var list = json['topPlayers']['goals'] as List;
      return TopScorerResponse(
        goals: list.map((e) => PlayerStats.fromJson(e)).toList(),
      );
    }
    return TopScorerResponse(goals: []);
  }
}

class PlayerStats {
  final int goals;
  final String playerName;
  final String playerShortName;
  final int teamId;
  final String teamName;

  PlayerStats({
    required this.goals,
    required this.playerName,
    required this.playerShortName,
    required this.teamId,
    required this.teamName,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      // Lấy số bàn thắng từ object 'statistics'
      goals: json['statistics']['goals'] ?? 0,
      // Lấy tên từ object 'player'
      playerName: json['player']['name'] ?? 'Unknown',
      playerShortName: json['player']['shortName'] ?? 'Unknown',
      // Lấy ID và tên đội từ object 'team'
      teamId: json['team']['id'] ?? 0,
      teamName: json['team']['name'] ?? 'Unknown',
    );
  }
}
