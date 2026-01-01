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

  Future<void> _updateTodo() async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('todos').update({
        'title': _titleController.text,
        'description': _descController.text,
        'notes': _notesController.text,
        'status': _selectedStatus,
        'priority': _selectedPriority,
        'due_date': _selectedDueDate?.toIso8601String().split('T')[0],
      }).eq('id', widget.todo['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal update: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
