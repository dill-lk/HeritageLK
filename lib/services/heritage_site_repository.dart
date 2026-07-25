import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/heritage_site.dart';

class HeritageSiteRepository {
  HeritageSiteRepository(this._client);

  final SupabaseClient _client;

  Future<List<HeritageSite>> listSites() async {
    final rows = await _client.from('heritage_sites').select().order('created_at', ascending: false);
    return rows.map((row) => HeritageSite.fromMap(row)).toList();
  }

  Future<HeritageSite?> findByTitle(String title) async {
    final rows = await _client.from('heritage_sites').select().ilike('title', '%$title%').limit(1);
    return rows.isEmpty ? null : HeritageSite.fromMap(rows.first);
  }
}
