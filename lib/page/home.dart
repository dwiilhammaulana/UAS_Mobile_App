import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lottie/lottie.dart'; // Pastikan package lottie sudah diinstall
import 'package:uas_mobile_app/page/add_todo.dart';

// Import halaman profile (sesuaikan dengan struktur projectmu)
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
  late Stream<List<Map<String, dynamic>>> _todoStream;

  // --- LOGIKA MULTI SELECT ---
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _initStream();
    _handleFcmToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      try {
        await supabase.from('firebase_tokens').upsert({
          'user_id': user.id,
          'fcm_token': newToken,
          'updated_at': DateTime.now().toIso8601String(),
        }).select();
      } catch (e) {
        debugPrint('FCM refresh save error: $e');
      }
    });
  }

  void _initStream() {
    final user = supabase.auth.currentUser;
    _todoStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', user?.id ?? '')
        .order('created_at', ascending: false);
  }

  // --- FUNGSI REFRESH (Tarik ke bawah) ---
  Future<void> _refreshData() async {
    setState(() {
      _initStream();
    });
    // Jeda sedikit agar animasi lottie sempat terlihat
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Future<void> _handleFcmToken() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;

      await supabase.from('firebase_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).select();
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  // --- FUNGSI HAPUS MASAL ---
  Future<void> _deleteSelectedTodos() async {
    final int count = _selectedIds.length;
    if (count == 0) return;

    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hapus $count Tugas?'),
            content: const Text(
                'Tugas yang dipilih akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
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
      await supabase
          .from('todos')
          .delete()
          .filter('id', 'in', _selectedIds.toList());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count tugas berhasil dihapus')),
      );

      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    } catch (e) {
      debugPrint('Delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _toggleStatus(String id, String currentStatus) async {
    if (_isSelectionMode) return;
    final String newStatus =
        currentStatus == 'completed' ? 'todo' : 'completed';
    try {
      await supabase
          .from('todos')
          .update({'status': newStatus}).eq('id', id);
    } catch (e) {
      debugPrint('Toggle status error: $e');
    }
  }

  // --- WIDGET LOTTIE LOADING ---
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/load/jump.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LOTTIE EMPTY STATE ---
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/load/jump.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada tugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk mulai',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileDetail3()));
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
    // PERBAIKAN: Kode yang menyembunyikan profil saat selection mode sudah DIHAPUS.
    // Profil akan selalu tampil.

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
                const Icon(Icons.arrow_forward_ios, size: 16),
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
          Text(count.toString(),
              style: TextStyle(
                  color: Colors.grey[500], fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    final bool isCompleted = item['status'] == 'completed';
    final String title = (item['title'] as String?) ?? '';
    final String priority = (item['priority'] as String?) ?? 'low';
    final String id = item['id'] as String;
    final bool isSelected = _selectedIds.contains(id);

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
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Material(
        color: isSelected ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(id);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TodoDetailPage(todo: item)));
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedIds.add(id);
              });
            } else {
              _toggleSelection(id);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFC107)
                    : Colors.black.withValues(alpha: 0.06),
                width: isSelected ? 2 : 1,
              ),
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
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? const Color(0xFFFFC107) : Colors.grey,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () =>
                        _toggleStatus(id, item['status'] as String),
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
                            Text(dueLabel,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
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
                        color: priorityColor.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 16, color: priorityColor),
                      const SizedBox(width: 6),
                      Text(
                        priority.toUpperCase(),
                        style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900),
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
      List<Map<String, dynamic>> items) {
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
    // PERBAIKAN: AppBar dibuat statis (tidak berubah meski isSelectionMode true)
    // agar header tetap "seperti biasa".
    final AppBar appBar = AppBar(
      title: const Text('Task Manager',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900)),
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
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: _buildLeftDrawer(),
      appBar: appBar,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _todoStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLoadingState();
          }

          final List<Map<String, dynamic>> todos = snapshot.data!;

          if (todos.isEmpty) {
            return _buildEmptyState();
          }

          final inProgress = _sortWithHighOnTop(
              todos.where((t) => t['status'] == 'in_progress').toList());
          final todoList = _sortWithHighOnTop(
              todos.where((t) => t['status'] == 'todo').toList());
          final pending = _sortWithHighOnTop(
              todos.where((t) => t['status'] == 'pending').toList());
          final completed = _sortWithHighOnTop(
              todos.where((t) => t['status'] == 'completed').toList());

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFFFFC107),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildProfileHeader(), // Profile tetap muncul
                if (inProgress.isNotEmpty) ...[
                  _buildSectionHeader(
                      'IN PROGRESS', inProgress.length, Colors.deepPurple),
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
                  _buildSectionHeader(
                      'COMPLETED', completed.length, Colors.green),
                  ...completed.map(_buildTaskItem),
                ],
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      // PERBAIKAN: Floating Action Button tetap berubah merah saat selection mode
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton.extended(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete_outline),
              label: Text('Hapus (${_selectedIds.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              onPressed: _deleteSelectedTodos,
            )
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('Tambah',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              onPressed: _showAddSheet,
            ),
    );
  }
}