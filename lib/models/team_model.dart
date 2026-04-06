class TeamModel {
  final String id;
  final String name;
  final String code;
  final String logo;
  final String description;
  final List<String> squad;

  TeamModel({
    required this.id,
    required this.name,
    required this.code,
    required this.logo,
    required this.description,
    required this.squad,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['teamId']?.toString() ?? '',
      name: json['teamName'] ?? '',
      code: json['teamSName'] ?? '',
      logo: json['imageId'] != null
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
      description: '', // Description usually comes from a different detail API
      squad: [], // Squad usually comes from a different detail API
    );
  }
}
