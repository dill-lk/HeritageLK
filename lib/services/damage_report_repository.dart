import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/damage_report.dart';

class DamageReportRepository {
  DamageReportRepository(this._client);

  final SupabaseClient _client;

  Future<void> submit({required String damageType, required String details, required String location}) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('damage_reports').insert({'location': location, 'damage_type': damageType, 'details': details, 'user_id': userId, 'status': 'pending'});
    if (userId != null) {
      try {
        await _client.rpc('increment_points', params: {'user_id_param': userId, 'points_to_add': 100});
      } catch (_) {
        // Some HeritageLK projects award report points with database triggers instead.
      }
    }
  }

  Future<List<DamageReport>> list({String? status}) async {
    final rows = status != null && status != 'all'
        ? await _client.from('damage_reports').select().eq('status', status).order('created_at', ascending: false)
        : await _client.from('damage_reports').select().order('created_at', ascending: false);
    return rows.map((row) => DamageReport.fromMap(row)).toList();
  }

  Future<void> updateStatus(String id, String status) => _client.from('damage_reports').update({'status': status}).eq('id', id);
}
