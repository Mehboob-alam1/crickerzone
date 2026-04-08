class PlayerModel {
  final String id;
  final String name;
  final String role;
  final String image;
  final String? dob;
  final String? birthPlace;
  final String? height;
  final String? batStyle;
  final String? bowlStyle;
  final String? team;
  final String runs;
  final String average;
  final Map<String, dynamic>? stats;

  PlayerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    this.dob,
    this.birthPlace,
    this.height,
    this.batStyle,
    this.bowlStyle,
    this.team,
    this.runs = 'N/A',
    this.average = 'N/A',
    this.stats,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id']?.toString() ?? json['playerId']?.toString() ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? json['teamName'] ?? '',
      image: (json['faceImageId'] != null || json['imageId'] != null)
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['faceImageId'] ?? json['imageId']}/i.jpg'
          : '',
      dob: json['dob']?.toString(),
      birthPlace: json['birthPlace'],
      height: json['height'],
      batStyle: json['bat'],
      bowlStyle: json['bowl'],
      team: json['teamName'] ?? json['intlTeam'],
      // runs: json['runs']?.toString() ?? 'N/A',
      average: json['avg']?.toString() ?? 'N/A',
    );
  }
}
