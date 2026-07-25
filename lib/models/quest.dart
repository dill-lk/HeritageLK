class Quest {
  const Quest({required this.id, required this.title, required this.description, required this.points, this.icon});

  final String id;
  final String title;
  final String description;
  final int points;
  final String? icon;

  factory Quest.fromMap(Map<String, dynamic> map) => Quest(
        id: '${map['id'] ?? ''}',
        title: '${map['title'] ?? ''}',
        description: '${map['description'] ?? ''}',
        points: (map['points'] as num?)?.toInt() ?? 0,
        icon: map['icon']?.toString(),
      );
}
