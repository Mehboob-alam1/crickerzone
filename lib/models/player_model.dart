class PlayerModel {
  final String id;
  final String name;
  final String role;
  final String image;
  final String runs;
  final String average;
  final String strikeRate;
  final String wickets;
  final String bestBowling;

  PlayerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    required this.runs,
    required this.average,
    required this.strikeRate,
    this.wickets = '0',
    this.bestBowling = 'N/A',
  });
}
