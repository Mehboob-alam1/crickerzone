class MatchModel {
  final String id;
  final String teamA;
  final String teamB;
  final String teamALogo;
  final String teamBLogo;
  final String scoreA; // e.g., "352/7"
  final String oversA; // e.g., "50.0"
  final String scoreB;
  final String oversB;
  final String status;
  final String matchType; // Live, Upcoming, Recent
  final String venue;
  final String time;
  final String series;

  MatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.teamALogo,
    required this.teamBLogo,
    required this.scoreA,
    required this.oversA,
    required this.scoreB,
    required this.oversB,
    required this.status,
    required this.matchType,
    required this.venue,
    required this.time,
    required this.series,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json, String type) {
    final info = json['matchInfo'] ?? {};
    final score = json['matchScore'] ?? {};
    
    String getScore(Map<String, dynamic> teamScore) {
      final inngs = teamScore['inngs1'];
      if (inngs == null) return '-';
      return '${inngs['runs']}/${inngs['wickets']}';
    }

    String getOvers(Map<String, dynamic> teamScore) {
      final inngs = teamScore['inngs1'];
      if (inngs == null) return '-';
      return '${inngs['overs']}';
    }

    return MatchModel(
      id: info['matchId']?.toString() ?? '',
      teamA: info['team1']?['teamName'] ?? 'TBA',
      teamB: info['team2']?['teamName'] ?? 'TBA',
      teamALogo: 'https://static.cricbuzz.com/a/img/v1/i1/c${info['team1']?['imageId']}/i.jpg',
      teamBLogo: 'https://static.cricbuzz.com/a/img/v1/i1/c${info['team2']?['imageId']}/i.jpg',
      scoreA: getScore(score['team1Score'] ?? {}),
      oversA: getOvers(score['team1Score'] ?? {}),
      scoreB: getScore(score['team2Score'] ?? {}),
      oversB: getOvers(score['team2Score'] ?? {}),
      status: info['status'] ?? '',
      matchType: type,
      venue: '${info['venueInfo']?['ground']}, ${info['venueInfo']?['city']}',
      time: info['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(info['startDate'])).toString() : 'TBA',
      series: info['seriesName'] ?? '',
    );
  }

  MatchModel copyWith({
    String? id,
    String? teamA,
    String? teamB,
    String? teamALogo,
    String? teamBLogo,
    String? scoreA,
    String? oversA,
    String? scoreB,
    String? oversB,
    String? status,
    String? matchType,
    String? venue,
    String? time,
    String? series,
  }) {
    return MatchModel(
      id: id ?? this.id,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      teamALogo: teamALogo ?? this.teamALogo,
      teamBLogo: teamBLogo ?? this.teamBLogo,
      scoreA: scoreA ?? this.scoreA,
      oversA: oversA ?? this.oversA,
      scoreB: scoreB ?? this.scoreB,
      oversB: oversB ?? this.oversB,
      status: status ?? this.status,
      matchType: matchType ?? this.matchType,
      venue: venue ?? this.venue,
      time: time ?? this.time,
      series: series ?? this.series,
    );
  }
}
