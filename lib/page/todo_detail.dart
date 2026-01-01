import 'package:flutter/material.dart';

class TodoDetailPage extends StatefulWidget {
  final Map<String, dynamic> todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task Detail"),
      ),
      body: const Center(
        child: Text("Todo Detail Page"),
      ),
    );
  }
}
