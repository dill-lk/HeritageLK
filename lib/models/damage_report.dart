class DamageReport {
  const DamageReport({
    required this.id,
    required this.location,
    required this.damageType,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String location;
  final String damageType;
  final String details;
  final String status;
  final DateTime createdAt;

  factory DamageReport.fromMap(Map<String, dynamic> map) {
    return DamageReport(
      id: '${map['id'] ?? ''}',
      location: '${map['location'] ?? ''}',
      damageType: '${map['damage_type'] ?? ''}',
      details: '${map['details'] ?? ''}',
      status: '${map['status'] ?? 'pending'}',
      createdAt: DateTime.tryParse('${map['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}
