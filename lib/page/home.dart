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
    return const Scaffold(
      body: Center(child: Text("Home")),
    );
  }
}
