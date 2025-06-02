class EmailMessage {
  final String id;
  final String content;
  List<String> tags;

  EmailMessage({required this.id, required this.content, this.tags = const []});

  String get tagsDisplay => tags.isEmpty ? 'Unclassified' : tags.join(', ');
}
