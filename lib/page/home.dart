import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedStatus = 'todo';
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String _reminderOffset = 'none';

  late final Stream<List<Map<String, dynamic>>> _todoStream;

  @override
  void initState() {
    super.initState();
    _todoStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _todoStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!;
          final todoList = todos.where((t) => t['status'] == 'todo').toList();
          final pending = todos.where((t) => t['status'] == 'pending').toList();
          final inProgress = todos.where((t) => t['status'] == 'in_progress').toList();
          final completed = todos.where((t) => t['status'] == 'completed').toList();

          return ListView(
            children: [
              if (todoList.isNotEmpty) Text("TODO (${todoList.length})"),
              if (pending.isNotEmpty) Text("PENDING (${pending.length})"),
              if (inProgress.isNotEmpty) Text("IN PROGRESS (${inProgress.length})"),
              if (completed.isNotEmpty) Text("COMPLETED (${completed.length})"),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}
