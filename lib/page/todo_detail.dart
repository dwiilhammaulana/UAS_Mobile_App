import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoDetailPage extends StatefulWidget {
  final Map<String, dynamic> todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;

  late String _selectedStatus;
  late String _selectedPriority;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

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
