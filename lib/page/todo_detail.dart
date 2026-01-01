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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo['title']);
    _descController = TextEditingController(text: widget.todo['description']);
    _notesController = TextEditingController(text: widget.todo['notes']);
    _selectedStatus = widget.todo['status'] ?? 'todo';
    _selectedPriority = widget.todo['priority'] ?? 'medium';

    if (widget.todo['due_date'] != null) {
      _selectedDueDate = DateTime.parse(widget.todo['due_date']);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
