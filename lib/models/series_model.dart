class SeriesModel {
  final String id;
  final String name;
  final String startDatestamp;
  final String endDatestamp;
  final String seriesType;
  final int? numMatches;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String? get startDate => _formatDatestamp(startDatestamp);
  String? get endDate => _formatDatestamp(endDatestamp);

  SeriesModel({
    required this.id,
    required this.name,
    required this.startDatestamp,
    required this.endDatestamp,
    required this.seriesType,
    this.numMatches,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      startDatestamp: (json['startDt'] ?? json['startDatestamp'])?.toString() ?? '',
      endDatestamp: (json['endDt'] ?? json['endDatestamp'])?.toString() ?? '',
      seriesType: json['seriesType']?.toString() ?? '',
      numMatches: _parseInt(
        json['numMatches'] ??
            json['matchCount'] ??
            json['matches'] ??
            json['numMat'],
      ),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _formatDatestamp(String? value) {
    if (value == null || value.isEmpty) return null;
    final millis = int.tryParse(value);
    if (millis == null || millis <= 0) return null;

    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}
