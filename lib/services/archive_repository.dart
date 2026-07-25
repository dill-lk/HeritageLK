import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/archive_record.dart';

class ArchiveRepository {
  ArchiveRepository(this._client);

  final SupabaseClient _client;

  Future<List<ArchiveRecord>> listArchives() async {
    final rows = await _client.from('archives').select().order('created_at', ascending: false);
    return rows.map((row) => ArchiveRecord.fromMap(row)).toList();
  }

  Future<ArchiveRecord?> getArchive(String id) async {
    final row = await _client.from('archives').select().eq('id', id).maybeSingle();
    return row == null ? null : ArchiveRecord.fromMap(row);
  }

  Future<ArchiveRecord?> createContribution({
    required String title,
    required String category,
    required String description,
    required bool isPublic,
  }) async {
    final intro = description.length > 50 ? '${description.substring(0, 50)}...' : '$description...';
    final row = await _client.from('archives').insert({
      'title': title,
      'category': category,
      'content': description,
      'intro': intro,
      'user_id': _client.auth.currentUser?.id,
      'location': 'User Uploaded',
      'image': 'https://images.unsplash.com/photo-1545657805-46eb13251a37?q=80&w=1000&auto=format&fit=crop',
    }).select().maybeSingle();
    return row == null ? null : ArchiveRecord.fromMap(row);
  }

  Future<ArchiveRecord?> createGeneratedArchive({
    required String title,
    required String content,
  }) async {
    final intro = content.length > 160 ? '${content.substring(0, 160)}...' : content;
    final row = await _client.from('archives').insert({
      'title': title,
      'subtitle': 'AI Generated Archive',
      'category': 'Ancient Sites',
      'content': content,
      'intro': intro,
      'user_id': _client.auth.currentUser?.id,
      'location': 'Sri Lanka',
      'image': 'https://images.unsplash.com/photo-1596706798032-9cb773b40bb0?q=80&w=1200&auto=format&fit=crop',
    }).select().maybeSingle();
    return row == null ? null : ArchiveRecord.fromMap(row);
  }
}
