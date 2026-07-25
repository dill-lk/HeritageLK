class Profile {
  const Profile({required this.id, required this.fullName, required this.points});

  final String id;
  final String fullName;
  final int points;

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: '${map['id'] ?? ''}',
        fullName: '${map['full_name'] ?? 'Explorer'}',
        points: (map['points'] as num?)?.toInt() ?? 0,
      );
}
