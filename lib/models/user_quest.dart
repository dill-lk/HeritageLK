class UserQuest {
  const UserQuest({required this.userId, required this.questId, required this.createdAt});

  final String userId;
  final String questId;
  final DateTime createdAt;

  factory UserQuest.fromMap(Map<String, dynamic> map) => UserQuest(
        userId: '${map['user_id'] ?? ''}',
        questId: '${map['quest_id'] ?? ''}',
        createdAt: DateTime.tryParse('${map['completed_at'] ?? map['created_at'] ?? ''}') ?? DateTime.now(),
      );
}
