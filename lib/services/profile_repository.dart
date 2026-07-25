import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> currentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<int> rankForPoints(int points) async {
    final rows = await _client.from('profiles').select('id').gt('points', points);
    return rows.length + 1;
  }

  Future<List<Profile>> leaderboard({int limit = 3}) async {
    final rows = await _client.from('profiles').select().order('points', ascending: false).limit(limit);
    return rows.map((row) => Profile.fromMap(row)).toList();
  }

  Future<void> signOut() => _client.auth.signOut();
}
