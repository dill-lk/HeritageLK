class Profile {
  const Profile({required this.id, required this.fullName, required this.points, this.city});

  final String id;
  final String fullName;
  final int points;
  final String? city;

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: '${map['id'] ?? ''}',
        fullName: '${map['full_name'] ?? 'Explorer'}',
        points: (map['points'] as num?)?.toInt() ?? 0,
        city: map['city']?.toString(),
      );
}
