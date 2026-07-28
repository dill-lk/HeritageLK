class DamageReport {
  const DamageReport({
    required this.id,
    required this.location,
    required this.damageType,
    required this.details,
    required this.status,
    required this.createdAt,
    this.photos = const [],
  });

  final String id;
  final String location;
  final String damageType;
  final String details;
  final String status;
  final DateTime createdAt;
  final List<String> photos;

  factory DamageReport.fromMap(Map<String, dynamic> map) {
    List<String> parsedPhotos = [];
    if (map['photos'] is List) {
      parsedPhotos = (map['photos'] as List).map((e) => '$e').toList();
    } else if (map['photo_url'] != null && '${map['photo_url']}'.isNotEmpty) {
      parsedPhotos = ['${map['photo_url']}'];
    }

    return DamageReport(
      id: '${map['id'] ?? ''}',
      location: '${map['location'] ?? ''}',
      damageType: '${map['damage_type'] ?? ''}',
      details: '${map['details'] ?? ''}',
      status: '${map['status'] ?? 'pending'}',
      createdAt: DateTime.tryParse('${map['created_at'] ?? ''}') ?? DateTime.now(),
      photos: parsedPhotos,
    );
  }
}
