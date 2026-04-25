class StandingResponse {
  final List<StandingRow> rows;

  StandingResponse({required this.rows});

  factory StandingResponse.fromJson(Map<String, dynamic> json) {
    // Dữ liệu thực tế nằm trong json['standings'][0]['rows']
    if (json['standings'] != null && (json['standings'] as List).isNotEmpty) {
      var firstStanding = json['standings'][0];
      var rowsList = firstStanding['rows'] as List;
      return StandingResponse(
        rows: rowsList.map((e) => StandingRow.fromJson(e)).toList(),
      );
    }
    return StandingResponse(rows: []);
  }
}

class StandingRow {
  final int position;
  final StandingTeam team;
  final int matches;
  final int wins;
  final int draws;
  final int losses;
  final int points;

  StandingRow({
    required this.position,
    required this.team,
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
  });

  factory StandingRow.fromJson(Map<String, dynamic> json) {
    return StandingRow(
      position: json['position'] ?? 0,
      team: StandingTeam.fromJson(json['team']),
      matches: json['matches'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      points: json['points'] ?? 0,
    );
  }
}

class StandingTeam {
  final int id;
  final String name;
  final String shortName;

  StandingTeam({required this.id, required this.name, required this.shortName});

  factory StandingTeam.fromJson(Map<String, dynamic> json) {
    return StandingTeam(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      shortName: json['shortName'] ?? json['name'] ?? 'Unknown',
    );
  }
}