class ArchiveRecord {
  const ArchiveRecord({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.content,
    this.image,
  });

  final String id;
  final String title;
  final String location;
  final String category;
  final String content;
  final String? image;

  factory ArchiveRecord.fromMap(Map<String, dynamic> map) {
    final images = map['images'];
    return ArchiveRecord(
      id: '${map['id'] ?? ''}',
      title: '${map['title'] ?? 'Archive Record'}',
      location: '${map['location'] ?? 'SRI LANKA'}',
      category: '${map['category'] ?? 'Artifacts'}',
      content: '${map['content'] ?? map['intro'] ?? ''}',
      image: map['image']?.toString() ?? (images is List && images.isNotEmpty ? '${images.first}' : null),
    );
  }
}
