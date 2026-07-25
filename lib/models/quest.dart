class Quest {
  const Quest({required this.id, required this.title, required this.description, required this.points});

  final String id;
  final String title;
  final String description;
  final int points;

  factory Quest.fromMap(Map<String, dynamic> map) => Quest(
        id: '${map['id'] ?? ''}',
        title: '${map['title'] ?? ''}',
        description: '${map['description'] ?? ''}',
        points: (map['points'] as num?)?.toInt() ?? 0,
      );
}
