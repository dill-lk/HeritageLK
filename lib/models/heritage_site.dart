class HeritageSite {
  const HeritageSite({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    this.locationName,
    this.lat,
    this.lng,
  });

  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String? locationName;
  final double? lat;
  final double? lng;

  factory HeritageSite.fromMap(Map<String, dynamic> map) => HeritageSite(
        id: '${map['id'] ?? ''}',
        title: '${map['title'] ?? 'Heritage Site'}',
        summary: '${map['summary'] ?? map['article_content'] ?? ''}',
        imageUrl: map['image_url']?.toString(),
        locationName: map['location_name']?.toString(),
        lat: (map['lat'] as num?)?.toDouble() ?? double.tryParse('${map['lat'] ?? ''}'),
        lng: (map['lng'] as num?)?.toDouble() ?? double.tryParse('${map['lng'] ?? ''}'),
      );
}
