class MatchResponse {
  final List<MatchEvent> events;

  MatchResponse({required this.events});

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    return MatchResponse(
      events: json['events'] != null
          ? (json['events'] as List).map((i) => MatchEvent.fromJson(i)).toList()
          : [],
    );
  }
}

class MatchEvent {
  final int id;
  final int startTimestamp;
  final Team homeTeam;
  final Team awayTeam;
  final Score? homeScore;
  final Score? awayScore;
  final MatchStatus status;

  MatchEvent({
    required this.id,
    required this.startTimestamp,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.status,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      id: json['id'],
      startTimestamp: json['startTimestamp'],
      homeTeam: Team.fromJson(json['homeTeam']),
      awayTeam: Team.fromJson(json['awayTeam']),
      homeScore: json['homeScore'] != null ? Score.fromJson(json['homeScore']) : null,
      awayScore: json['awayScore'] != null ? Score.fromJson(json['awayScore']) : null,
      status: MatchStatus.fromJson(json['status']),
    );
  }
}

class Team {
  final int id;
  final String name;
  final String shortName;

  Team({required this.id, required this.name, required this.shortName});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'] ?? json['name'],
    );
  }
}

class Score {
  final int? display;

  Score({this.display});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      display: json['display'],
    );
  }
}

class MatchStatus {
  final String description; // VD: "Ended", "Not started"

  MatchStatus({required this.description});

  factory MatchStatus.fromJson(Map<String, dynamic> json) {
    return MatchStatus(
      description: json['description'],
    );
  }
}