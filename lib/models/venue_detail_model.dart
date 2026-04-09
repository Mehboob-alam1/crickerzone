class VenueDetailModel {
  final String ground;
  final String city;
  final String country;
  final String timezone;
  final String capacity;
  final String ends;
  final String homeTeam;
  final String imageUrl;
  final String imageId;

  VenueDetailModel({
    required this.ground,
    required this.city,
    required this.country,
    required this.timezone,
    required this.capacity,
    required this.ends,
    required this.homeTeam,
    required this.imageUrl,
    required this.imageId,
  });

  factory VenueDetailModel.fromJson(Map<String, dynamic> json) {
    return VenueDetailModel(
      ground: json['ground']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      ends: json['ends']?.toString() ?? '',
      homeTeam: json['homeTeam']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      imageId: json['imageId']?.toString() ?? '',
    );
  }
}

class VenueStatRow {
  final String key;
  final String value;

  VenueStatRow({required this.key, required this.value});

  factory VenueStatRow.fromJson(Map<String, dynamic> json) {
    return VenueStatRow(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  static List<VenueStatRow> listFromResponse(dynamic raw) {
    if (raw is! Map || raw['venueStats'] is! List) return [];
    return (raw['venueStats'] as List)
        .whereType<Map>()
        .map((e) => VenueStatRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
