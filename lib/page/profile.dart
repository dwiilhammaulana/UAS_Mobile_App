import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uas_mobile_app/page/home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final String userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _fullNameController.text = (data['full_name'] ?? '').toString();
        _usernameController.text = (data['username'] ?? '').toString();
        setState(() {
          _imageUrl = data['avatar_url']?.toString();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final File file = File(image.path);
      final String userId = supabase.auth.currentUser!.id;
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('todo-image').upload(fileName, file);

      final String publicUrl =
          supabase.storage.from('todo-image').getPublicUrl(fileName);

      if (!mounted) return;

      setState(() => _imageUrl = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto berhasil diunggah!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal upload: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
  setState(() => _isLoading = true);
  try {
    final user = supabase.auth.currentUser!;
    await supabase.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'full_name': _fullNameController.text,
      'username': _usernameController.text,
      'avatar_url': _imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFFFC107);
    const Color dark = Color(0xFF111827);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: accent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              _CardShell(
                child: Column(
                  children: [
                    _AvatarHeader(
                      imageUrl: _imageUrl,
                      onTap: _pickAndUploadImage,
                      accent: accent,
                    ),
                    const SizedBox(height: 18),
                    const _InfoRow(
                      icon: Icons.verified_user_rounded,
                      title: "Akun",
                      subtitle: "Perbarui data profil kamu",
                      accent: accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _CardShell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informasi Profil",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      _fullNameController,
                      "Nama Lengkap",
                      Icons.person_rounded,
                    ),
                    _buildTextField(
                      _usernameController,
                      "Username",
                      Icons.alternate_email_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Pastikan data yang kamu isi sudah benar.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF111827), width: 1.2),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: focusedBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.imageUrl,
    required this.onTap,
    required this.accent,
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (imageUrl ?? '').isNotEmpty;

    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.95),
                        const Color(0xFFFFE082),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        hasImage ? NetworkImage(imageUrl!) : null,
                    child: hasImage
                        ? null
                        : const Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: Color(0xFF6B7280),
                          ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          hasImage ? "Ubah foto profil" : "Tambah foto profil",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Ketuk foto untuk memilih dari galeri",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.28),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF111827)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
