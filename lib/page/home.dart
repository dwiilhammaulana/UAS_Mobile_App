import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uas_mobile_app/page/add_todo.dart';

import 'package:uas_mobile_app/page/profile.dart';
import 'package:uas_mobile_app/page/profiledetail1.dart';
import 'package:uas_mobile_app/page/profiledetail2.dart';
import 'package:uas_mobile_app/page/profiledetail3.dart';
import 'package:uas_mobile_app/page/profiledetail4.dart';
import 'package:uas_mobile_app/page/todo_detail.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Stream<List<Map<String, dynamic>>> _todoStream;

  @override
  void initState() {
    super.initState();
    _handleFcmToken();
    _todoStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _handleFcmToken() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? token = await messaging.getToken();

      if (token != null) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase.from('firebase_tokens').upsert({
            'user_id': user.id,
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  Future<void> _deleteTodo(String id) async {
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Tugas'),
            content: const Text('Yakin ingin menghapus tugas ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('BATAL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('HAPUS', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await supabase.from('todos').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terhapus')),
      );
    } catch (e) {
      debugPrint('Delete todo error: $e');
    }
  }

  Future<void> _toggleStatus(String id, String currentStatus) async {
    final String newStatus =
        currentStatus == 'completed' ? 'todo' : 'completed';
    try {
      await supabase.from('todos').update({'status': newStatus}).eq('id', id);
    } catch (e) {
      debugPrint('Toggle status error: $e');
    }
  }

  Drawer _buildLeftDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'Kelompok Anak Baik',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Dwi ilham maulana - 1123150008'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileDetail3()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Lendra - 1123150'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileDetail1()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ramzy - 1123150'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileDetail2()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ulin Nuha - 1123150002'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileDetail4()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Swipe dari kiri untuk buka menu.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTodoSheet(supabase: supabase),
    );
  }

  Widget _buildProfileHeader() {
    final user = supabase.auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', user.id),
      builder: (context, snapshot) {
        String name = user.email?.split('@')[0] ?? 'User';
        String? avatarUrl;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          name = (snapshot.data![0]['full_name'] as String?) ?? name;
          avatarUrl = snapshot.data![0]['avatar_url'] as String?;
        }

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF4CC), Color(0xFFFFE082)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFFFC107),
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=$name&background=FFC107&color=111827',
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, selamat datang',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    final bool isCompleted = item['status'] == 'completed';
    final String title = (item['title'] as String?) ?? '';
    final String priority = (item['priority'] as String?) ?? 'low';

    final Color priorityColor = priority == 'high'
        ? Colors.red
        : (priority == 'medium' ? Colors.amber : Colors.grey);

    final String? dueDate = item['due_date'] as String?;
    final String? dueTime = item['due_time'] as String?;

    String? dueLabel;
    if (dueDate != null && dueDate.isNotEmpty) {
      try {
        final DateTime parsed = DateTime.parse(dueDate);
        final String dateText = DateFormat('dd MMM').format(parsed);
        if (dueTime != null && dueTime.isNotEmpty) {
          final String timeText =
              dueTime.length >= 5 ? dueTime.substring(0, 5) : dueTime;
          dueLabel = '$dateText • $timeText';
        } else {
          dueLabel = dateText;
        }
      } catch (_) {
        dueLabel = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TodoDetailPage(todo: item)),
          ),
          onLongPress: () => _deleteTodo(item['id'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _toggleStatus(
                    item['id'] as String,
                    item['status'] as String,
                  ),
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : Colors.black87,
                        ),
                      ),
                      if (dueLabel != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.event,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              dueLabel,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: priorityColor.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 16, color: priorityColor),
                      const SizedBox(width: 6),
                      Text(
                        priority.toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _sortWithHighOnTop(
    List<Map<String, dynamic>> items,
  ) {
    final List<Map<String, dynamic>> result =
        List<Map<String, dynamic>>.from(items);
    result.sort((a, b) {
      final String pa = (a['priority'] as String?) ?? 'low';
      final String pb = (b['priority'] as String?) ?? 'low';
      if (pa == pb) return 0;
      if (pa == 'high') return -1;
      if (pb == 'high') return 1;
      return 0;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      resizeToAvoidBottomInset: false,
      drawer: _buildLeftDrawer(),
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await supabase.auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _todoStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> todos = snapshot.data!;
          final List<Map<String, dynamic>> inProgress = _sortWithHighOnTop(
            todos.where((t) => t['status'] == 'in_progress').toList(),
          );
          final List<Map<String, dynamic>> todoList = _sortWithHighOnTop(
            todos.where((t) => t['status'] == 'todo').toList(),
          );
          final List<Map<String, dynamic>> pending = _sortWithHighOnTop(
            todos.where((t) => t['status'] == 'pending').toList(),
          );
          final List<Map<String, dynamic>> completed = _sortWithHighOnTop(
            todos.where((t) => t['status'] == 'completed').toList(),
          );

          if (todos.isEmpty) {
            return ListView(
              children: [
                _buildProfileHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 44),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tekan tombol + untuk menambahkan tugas baru.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            );
          }

          return ListView(
            children: [
              _buildProfileHeader(),
              if (inProgress.isNotEmpty) ...[
                _buildSectionHeader(
                  'IN PROGRESS',
                  inProgress.length,
                  Colors.deepPurple,
                ),
                ...inProgress.map(_buildTaskItem),
              ],
              if (todoList.isNotEmpty) ...[
                _buildSectionHeader('TO DO', todoList.length, Colors.grey),
                ...todoList.map(_buildTaskItem),
              ],
              if (pending.isNotEmpty) ...[
                _buildSectionHeader('PENDING', pending.length, Colors.blue),
                ...pending.map(_buildTaskItem),
              ],
              if (completed.isNotEmpty) ...[
                _buildSectionHeader('COMPLETED', completed.length, Colors.green),
                ...completed.map(_buildTaskItem),
              ],
              const SizedBox(height: 120),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        onPressed: _showAddSheet,
      ),
    );
  }
}
