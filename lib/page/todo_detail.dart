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
        const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update: $e"), backgroundColor: Colors.red),
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
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : IconButton(
                  onPressed: _updateTodo,
                  icon: const Icon(Icons.save_as_rounded, size: 28),
                ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: "Judul Tugas",
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Keterangan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Tambahkan keterangan...",
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Catatan Tambahan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Catatan tambahan di sini...",
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _updateTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.save),
            label: const Text("SIMPAN PERUBAHAN"),
          ),
        ],
      ),
    );
  }
}
