import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';

class AddTodoSheet extends StatefulWidget {
  final SupabaseClient supabase;
  const AddTodoSheet({super.key, required this.supabase});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedStatus = 'todo';
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String _reminderOffset = 'none';

  bool _isAlarm = false;
  bool _isLoading = false; // Mencegah double tap tombol simpan

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty ||
        _selectedDueDate == null ||
        _selectedDueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi Judul, Tanggal, dan Jam')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Hitung Waktu Jatuh Tempo
    final DateTime fullDueDateTime = DateTime(
      _selectedDueDate!.year,
      _selectedDueDate!.month,
      _selectedDueDate!.day,
      _selectedDueTime!.hour,
      _selectedDueTime!.minute,
    );

    // 3. Hitung Waktu Pengingat
    DateTime? reminderFullDateTime;
    if (_reminderOffset == '1_hour') {
      reminderFullDateTime = fullDueDateTime.subtract(const Duration(hours: 1));
    } else if (_reminderOffset == '3_hours') {
      reminderFullDateTime = fullDueDateTime.subtract(const Duration(hours: 3));
    } else if (_reminderOffset == '1_day') {
      reminderFullDateTime = fullDueDateTime.subtract(const Duration(days: 1));
    }

    try {
      // 4. Simpan ke Supabase
      final user = widget.supabase.auth.currentUser;
      if (user != null) {
        final response = await widget.supabase.from('todos').insert({
          'user_id': user.id,
          'title': _titleController.text,
          'description': _descController.text,
          'status': _selectedStatus,
          'priority': _selectedPriority,
          'due_date': DateFormat('yyyy-MM-dd').format(fullDueDateTime),
          'due_time': DateFormat('HH:mm:ss').format(fullDueDateTime),
          'reminder_date': reminderFullDateTime != null
              ? DateFormat('yyyy-MM-dd').format(reminderFullDateTime)
              : null,
          'reminder_time': reminderFullDateTime != null
              ? DateFormat('HH:mm:ss').format(reminderFullDateTime)
              : null,
          'reminder_sent': false,
          'is_alarm': _isAlarm,
        }).select();

        // 5. Jadwalkan Alarm (Hanya jika user memilih alarm)
        if (_isAlarm && reminderFullDateTime != null) {
          if (reminderFullDateTime.isAfter(DateTime.now())) {
            
            final newTodo = response.first;
            final int alarmId = (newTodo['id'].toString().hashCode).abs(); 

            // --- KONFIGURASI ALARM ---
            final alarmSettings = AlarmSettings(
              id: alarmId,
              dateTime: reminderFullDateTime,
              assetAudioPath: 'assets/alarm/alarm.wav', 
              loopAudio: true, // Bunyi terus
              vibrate: true,
              volume: 1.0, 
              fadeDuration: 3.0,
              
              // SETTING PENTING: TOMBOL MATIKAN DI NOTIFIKASI
              notificationSettings: NotificationSettings(
                title: "Pengingat: ${_titleController.text}",
                body: "Waktunya mengerjakan tugas! Tekan tombol MATIKAN untuk stop.",
                stopButton: "MATIKAN", // Tombol ini muncul di notifikasi
                icon: 'ic_launcher',
              ),
            );

            await Alarm.set(alarmSettings: alarmSettings);
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil disimpan')),
      );

    } catch (e) {
      debugPrint('Insert todo error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tambah Tugas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Judul
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Keterangan
              TextField(
                controller: _descController,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Status & Prioritas
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: const ['todo', 'pending', 'in_progress', 'completed']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                      decoration: InputDecoration(
                        labelText: 'Status',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      items: const ['low', 'medium', 'high']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v!),
                      decoration: InputDecoration(
                        labelText: 'Prioritas',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Reminder Offset
              DropdownButtonFormField<String>(
                value: _reminderOffset,
                items: const [
                  {'label': 'Tanpa Pengingat', 'value': 'none'},
                  {'label': '1 Jam Sebelum', 'value': '1_hour'},
                  {'label': '3 Jam Sebelum', 'value': '3_hours'},
                  {'label': '1 Hari Sebelum', 'value': '1_day'},
                ].map((item) => DropdownMenuItem(value: item['value'], child: Text(item['label']!))).toList(),
                onChanged: (v) {
                  setState(() {
                    _reminderOffset = v!;
                    if (v == 'none') _isAlarm = false;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Ingatkan Saya',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Switch Alarm
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  activeColor: const Color(0xFF111827),
                  title: const Text('Mode Alarm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Bunyi looping + tombol stop', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _isAlarm,
                  onChanged: _reminderOffset == 'none'
                      ? null
                      : (bool value) => setState(() => _isAlarm = value),
                ),
              ),

              const SizedBox(height: 14),

              // Tanggal & Jam
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedDueDate == null ? 'Set Tanggal' : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (d != null) setState(() => _selectedDueDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedDueTime == null ? 'Set Jam' : _selectedDueTime!.format(context),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (t != null) setState(() => _selectedDueTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SIMPAN TUGAS', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}