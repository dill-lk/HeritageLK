import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quest.dart';
import '../models/user_quest.dart';

class QuestRepository {
  QuestRepository(this._client);

  final SupabaseClient _client;

  Future<List<Quest>> listQuests() async {
    final rows = await _client.from('quests').select().order('created_at');
    return rows.map((row) => Quest.fromMap(row)).toList();
  }

  Future<List<UserQuest>> completedQuests() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _client.from('user_quests').select().eq('user_id', user.id).order('completed_at', ascending: false);
    return rows.map((row) => UserQuest.fromMap(row)).toList();
  }

  Future<void> completeQuest(String questId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('You must be signed in to complete a quest.');
    await _client.from('user_quests').insert({'user_id': user.id, 'quest_id': questId});
  }
}
