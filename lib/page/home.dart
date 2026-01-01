import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uas_mobile_app/page/todo_detail.dart';
import 'package:uas_mobile_app/page/profile.dart';

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

  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty || _selectedDueDate == null || _selectedDueTime == null) return;

    final DateTime fullDueDateTime = DateTime(
      _selectedDueDate!.year,
      _selectedDueDate!.month,
      _selectedDueDate!.day,
      _selectedDueTime!.hour,
      _selectedDueTime!.minute,
    );
  }

  void _showAddSheet() {
    _titleController.clear();
    _descController.clear();
    _selectedStatus = 'todo';
    _selectedPriority = 'medium';
    _selectedDueDate = null;
    _selectedDueTime = null;
    _reminderOffset = 'none';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul")),
                TextField(controller: _descController, decoration: const InputDecoration(labelText: "Keterangan")),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: ['todo', 'pending', 'in_progress', 'completed']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                            .toList(),
                        onChanged: (v) => setModalState(() => _selectedStatus = v!),
                        decoration: const InputDecoration(labelText: "Status"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        items: ['low', 'medium', 'high']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                            .toList(),
                        onChanged: (v) => setModalState(() => _selectedPriority = v!),
                        decoration: const InputDecoration(labelText: "Prioritas"),
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _reminderOffset,
                  decoration: const InputDecoration(labelText: "Ingatkan Saya"),
                  items: [
                    {'label': 'Tanpa Pengingat', 'value': 'none'},
                    {'label': '1 Jam Sebelum', 'value': '1_hour'},
                    {'label': '3 Jam Sebelum', 'value': '3_hours'},
                    {'label': '1 Hari Sebelum', 'value': '1_day'},
                  ].map((item) => DropdownMenuItem(value: item['value'], child: Text(item['label']!))).toList(),
                  onChanged: (v) => setModalState(() => _reminderOffset = v!),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_selectedDueDate == null ? "Set Tanggal" : DateFormat('dd/MM/yyyy').format(_selectedDueDate!)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setModalState(() => _selectedDueDate = date);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_selectedDueTime == null ? "Set Jam" : _selectedDueTime!.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) setModalState(() => _selectedDueTime = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTodo,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white),
                    child: const Text("SIMPAN TUGAS"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTodo(String id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Tugas"),
            content: const Text("Yakin ingin menghapus tugas ini?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("BATAL")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("HAPUS", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await supabase.from('todos').delete().eq('id', id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terhapus")));
      } catch (e) {
        debugPrint("Error hapus: $e");
      }
    }
  }

  Future<void> _toggleStatus(String id, String currentStatus) async {
    final String newStatus = currentStatus == 'completed' ? 'todo' : 'completed';
    await supabase.from('todos').update({'status': newStatus}).eq('id', id);
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(count.toString(), style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    bool isCompleted = item['status'] == 'completed';
    Color flagColor = item['priority'] == 'high' ? Colors.red : (item['priority'] == 'medium' ? Colors.amber : Colors.grey);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TodoDetailPage(todo: item))),
        onLongPress: () => _deleteTodo(item['id']),
        contentPadding: EdgeInsets.zero,
        leading: IconButton(
          icon: Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? Colors.green : Colors.grey[300]),
          onPressed: () => _toggleStatus(item['id'], item['status']),
        ),
        title: Text(
          item['title'] ?? '',
          style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null, color: isCompleted ? Colors.grey : Colors.black87),
        ),
        trailing: Icon(Icons.flag, color: flagColor, size: 18),
      ),
    );
  }
  Widget _buildProfileHeader() {
  final user = supabase.auth.currentUser;
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', user!.id),
    builder: (context, snapshot) {
      String name = user.email?.split('@')[0] ?? "User";
      String? avatarUrl;

      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        name = snapshot.data![0]['full_name'] ?? name;
        avatarUrl = snapshot.data![0]['avatar_url'];
      }

      return InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFFC107),
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : NetworkImage(
                        'https://ui-avatars.com/api/?name=$name&background=FFC107&color=fff',
                      ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Haii, selamat datang",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Task Manager", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final todos = snapshot.data!;
          final inProgress = todos.where((t) => t['status'] == 'in_progress').toList();
          final todoList = todos.where((t) => t['status'] == 'todo').toList();
          final pending = todos.where((t) => t['status'] == 'pending').toList();
          final completed = todos.where((t) => t['status'] == 'completed').toList();

          return ListView(
            children: [
              _buildProfileHeader(),
              if (inProgress.isNotEmpty) ...[
                _buildSectionHeader("IN PROGRESS", inProgress.length, Colors.deepPurple),
                ...inProgress.map((e) => _buildTaskItem(e)),
              ],
              if (todoList.isNotEmpty) ...[
                _buildSectionHeader("TO DO", todoList.length, Colors.grey),
                ...todoList.map((e) => _buildTaskItem(e)),
              ],
              if (pending.isNotEmpty) ...[
                _buildSectionHeader("PENDING", pending.length, Colors.blue),
                ...pending.map((e) => _buildTaskItem(e)),
              ],
              if (completed.isNotEmpty) ...[
                _buildSectionHeader("COMPLETED", completed.length, Colors.green),
                ...completed.map((e) => _buildTaskItem(e)),
              ],
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
        onPressed: () => _showAddSheet(),
      ),
    );
  }
}
