import 'package:flutter/material.dart';

class ProfileDetail extends StatelessWidget {
  const ProfileDetail({super.key});

  // =========================
  // DATA MAHASISWA (WAJIB EDIT)
  // =========================
  static const String nama = "Dwi Ilham Maulana";
  static const String nim = "1123150008";
  static const String kelas = "TISE23M";

  // Foto sekarang dari assets
  static const String fotoAsset = "assets/images/ilham.png";

  // Keahlian (sudah diubah)
  static const List<String> keahlian = [
    "Backend Developer",
    "UI Developer",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: const Color(0xFF111827),
        centerTitle: true,
        title: const Text(
          "Profile Mahasiswa",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Column(
          children: [
            // =====================
            // HERO CARD (Foto + Nama + Badge)
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFFECB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Foto dengan border + shadow
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFFF3F4F6),
                      backgroundImage: const AssetImage(fotoAsset),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badge status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 18, color: Color(0xFF111827)),
                        SizedBox(width: 8),
                        Text(
                          "Mahasiswa Aktif",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =====================
            // CARD DATA DIRI (lebih clean)
            // =====================
            _SectionCard(
              title: "Data Diri",
              icon: Icons.person,
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.badge_outlined,
                    label: "NIM",
                    value: nim,
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  _infoRow(
                    icon: Icons.class_outlined,
                    label: "Kelas",
                    value: kelas,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =====================
            // CARD KEAHLIAN (chip lebih bagus + icon)
            // =====================
            _SectionCard(
              title: "Keahlian",
              icon: Icons.workspace_premium_outlined,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: keahlian.map((skill) {
                    final icon = _skillIcon(skill);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFFFC107).withOpacity(0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18, color: const Color(0xFF111827)),
                          const SizedBox(width: 8),
                          Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================
            // FOOTER
            // =====================
            Text(
              "Profile dibuat menggunakan Flutter",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // ICON UNTUK TIAP SKILL
  // =====================
  IconData _skillIcon(String skill) {
    final s = skill.toLowerCase();
    if (s.contains("backend")) return Icons.dns_outlined;
    if (s.contains("ui")) return Icons.design_services_outlined;
    return Icons.star_outline;
  }

  // =====================
  // WIDGET BARIS INFO (lebih rapi)
  // =====================
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF111827), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================
// REUSABLE SECTION CARD
// =====================
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF111827), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
