class TeamModel {
  final String id;
  final String name;
  final String code;
  final String logo;
  final String description;
  final List<String> squad;
  /// Righe solo titolo da `teams/list` (es. "Test Teams", "Associate Teams").
  final bool isSectionHeader;

  TeamModel({
    required this.id,
    required this.name,
    required this.code,
    required this.logo,
    required this.description,
    required this.squad,
    this.isSectionHeader = false,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final teamId = json['teamId'];
    final isHeader = teamId == null;
    final name = json['teamName']?.toString() ?? json['name']?.toString() ?? '';
    return TeamModel(
      id: isHeader ? '' : teamId.toString(),
      name: name,
      code: json['teamSName']?.toString() ?? '',
      logo: json['imageId'] != null
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
      description: '',
      squad: [],
      isSectionHeader: isHeader,
    );
  }
}
