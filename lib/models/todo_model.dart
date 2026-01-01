class Todo {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
  });
}
