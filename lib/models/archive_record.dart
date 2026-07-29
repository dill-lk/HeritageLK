class ArchiveRecord {
  const ArchiveRecord({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.content,
    this.subtitle,
    this.image,
  });

  final String id;
  final String title;
  final String location;
  final String category;
  final String content;
  final String? subtitle;
  final String? image;

  factory ArchiveRecord.fromMap(Map<String, dynamic> map) {
    final images = map['images'];
    String? textOf(String key) {
      final value = map[key];
      final text = value == null ? '' : '$value'.trim();
      return text.isEmpty ? null : text;
    }

    String pickText(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final text = textOf(key);
        if (text != null) return text;
      }
      return fallback;
    }

    return ArchiveRecord(
      id: '${map['id'] ?? ''}',
      title: '${map['title'] ?? 'Archive Record'}',
      location: '${map['location'] ?? 'SRI LANKA'}',
      category: '${map['category'] ?? 'Artifacts'}',
      subtitle: pickText(const ['subtitle', 'headline', 'summary']),
      content: pickText(const ['content', 'description', 'details', 'body', 'text', 'intro']),
      image: map['image']?.toString() ?? (images is List && images.isNotEmpty ? '${images.first}' : null),
    );
  }
}
