class MatchScheduleModel {
  final String date;
  final List<SeriesSchedule> seriesSchedules;

  MatchScheduleModel({
    required this.date,
    required this.seriesSchedules,
  });

  factory MatchScheduleModel.fromJson(Map<String, dynamic> json) {
    final wrapper = json['scheduleAdWrapper'] ?? {};
    final list = wrapper['matchScheduleList'] as List? ?? [];
    
    return MatchScheduleModel(
      date: wrapper['date'] ?? '',
      seriesSchedules: list.map((e) => SeriesSchedule.fromJson(e)).toList(),
    );
  }
}

class SeriesSchedule {
  final String seriesName;
  final int seriesId;
  final List<ScheduleMatchInfo> matches;

  SeriesSchedule({
    required this.seriesName,
    required this.seriesId,
    required this.matches,
  });

  factory SeriesSchedule.fromJson(Map<String, dynamic> json) {
    final list = json['matchInfo'] as List? ?? [];
    return SeriesSchedule(
      seriesName: json['seriesName'] ?? '',
      seriesId: json['seriesId'] ?? 0,
      matches: list.map((e) => ScheduleMatchInfo.fromJson(e)).toList(),
    );
  }
}

class ScheduleMatchInfo {
  final int matchId;
  final String matchDesc;
  final String matchFormat;
  final DateTime startDate;
  final TeamInfo team1;
  final TeamInfo team2;
  final VenueInfo venueInfo;

  ScheduleMatchInfo({
    required this.matchId,
    required this.matchDesc,
    required this.matchFormat,
    required this.startDate,
    required this.team1,
    required this.team2,
    required this.venueInfo,
  });

  factory ScheduleMatchInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleMatchInfo(
      matchId: json['matchId'] ?? 0,
      matchDesc: json['matchDesc'] ?? '',
      matchFormat: json['matchFormat'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['startDate'] ?? '0')),
      team1: TeamInfo.fromJson(json['team1'] ?? {}),
      team2: TeamInfo.fromJson(json['team2'] ?? {}),
      venueInfo: VenueInfo.fromJson(json['venueInfo'] ?? {}),
    );
  }
}

class TeamInfo {
  final int teamId;
  final String teamName;
  final String teamSName;
  final String image;

  TeamInfo({
    required this.teamId,
    required this.teamName,
    required this.teamSName,
    required this.image,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      teamId: json['teamId'] ?? 0,
      teamName: json['teamName'] ?? '',
      teamSName: json['teamSName'] ?? '',
      image: json['imageId'] != null 
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
    );
  }
}

class VenueInfo {
  final String ground;
  final String city;
  final String country;

  VenueInfo({
    required this.ground,
    required this.city,
    required this.country,
  });

  factory VenueInfo.fromJson(Map<String, dynamic> json) {
    return VenueInfo(
      ground: json['ground'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }
}
