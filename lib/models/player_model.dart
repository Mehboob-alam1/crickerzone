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
  final String? country;
  final String? rating;
  final String runs;
  final String average;
  final Map<String, dynamic>? stats;
  final String? bio;
  final String? nickName;
  final String? teamsClubs;

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
    this.country,
    this.rating,
    this.runs = 'N/A',
    this.average = 'N/A',
    this.stats,
    this.bio,
    this.nickName,
    this.teamsClubs,
  });

  static String _resolveImageUrl(Map<String, dynamic> json) {
    final direct = json['image']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    final fid = json['faceImageId'] ?? json['imageId'];
    if (fid == null) return '';
    return 'https://static.cricbuzz.com/a/img/v1/i1/c$fid/i.jpg';
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final roleField = json['role']?.toString() ?? '';
    final teamName = json['teamName']?.toString();
    final intlTeam = json['intlTeam']?.toString();
    final country = json['country']?.toString() ?? intlTeam ?? teamName;

    return PlayerModel(
      id: json['id']?.toString() ?? json['playerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: roleField.isNotEmpty ? roleField : (teamName ?? ''),
      image: _resolveImageUrl(json),
      dob: json['DoB']?.toString() ??
          json['DoBFormat']?.toString() ??
          json['dob']?.toString(),
      birthPlace: json['birthPlace']?.toString(),
      height: json['height']?.toString(),
      batStyle: json['bat']?.toString(),
      bowlStyle: json['bowl']?.toString(),
      team: intlTeam ?? teamName,
      country: country,
      rating: json['rating']?.toString() ?? json['avg']?.toString(),
      runs: json['runs']?.toString() ?? 'N/A',
      average: json['avg']?.toString() ?? 'N/A',
      bio: json['bio']?.toString(),
      nickName: json['nickName']?.toString(),
      teamsClubs: json['teams']?.toString(),
    );
  }
}
