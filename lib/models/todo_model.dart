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

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
