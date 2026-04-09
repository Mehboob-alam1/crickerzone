class SeriesModel {
  final String id;
  final String name;
  final String startDatestamp;
  final String endDatestamp;
  final String seriesType;

  SeriesModel({
    required this.id,
    required this.name,
    required this.startDatestamp,
    required this.endDatestamp,
    required this.seriesType,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      startDatestamp: (json['startDt'] ?? json['startDatestamp'])?.toString() ?? '',
      endDatestamp: (json['endDt'] ?? json['endDatestamp'])?.toString() ?? '',
      seriesType: json['seriesType']?.toString() ?? '',
    );
  }
}
