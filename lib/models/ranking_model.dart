class RankingModel {
  final String? id;
  final String? rank;
  final String? name;
  final String? country;
  final String? rating;
  final String? points;
  final String? imageId;

  RankingModel({
    this.id,
    this.rank,
    this.name,
    this.country,
    this.rating,
    this.points,
    this.imageId,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      id: json['id']?.toString(),
      rank: json['rank']?.toString(),
      name: json['name'] ?? json['teamName'],
      country: json['country'],
      rating: json['rating']?.toString(),
      points: json['points']?.toString(),
      imageId: json['faceId']?.toString() ?? json['imageId']?.toString(),
    );
  }
}
