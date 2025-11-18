import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Jawara',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close dialog
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close dialog
                          context.go('/login'); // Navigate to login
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Welcome text
              Text(
                'Selamat Datang',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              // Deskripsi di bawah judul dihilangkan sesuai permintaan
              const SizedBox(height: 32),

              // Menu Cards - Row 1
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Log Aktivitas',
                      subtitle: 'Riwayat aktivitas',
                      icon: Icons.history_outlined,
                      color: Colors.indigo,
                      onTap: () => context.go('/activity-log'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Pengguna',
                      subtitle: 'Kelola akun',
                      icon: Icons.people_outlined,
                      color: Colors.purple,
                      onTap: () => context.go('/user-list'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 2
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Pengeluaran',
                      subtitle: 'Data pengeluaran',
                      icon: Icons.payments_outlined,
                      color: Colors.red,
                      onTap: () => context.go('/pengeluaran'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Mutasi Keluarga',
                      subtitle: 'Perpindahan warga',
                      icon: Icons.swap_horiz,
                      color: Colors.orange,
                      onTap: () => context.go('/mutasi-keluarga'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 3
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Channel Transfer',
                      subtitle: 'Metode pembayaran',
                      icon: Icons.account_balance_outlined,
                      color: Colors.teal,
                      onTap: () => context.go('/channel-transfer'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Daftar Pemasukan',
                      subtitle: 'Catatan pemasukan kas',
                      icon: Icons.trending_up_outlined,
                      color: Colors.green,
                      onTap: () => context.go(AppRoutes.pemasukan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 4
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Data Rumah',
                      subtitle: 'Kelola data rumah',
                      icon: Icons.home_outlined,
                      color: Colors.blue,
                      onTap: () => context.go('/rumah'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Data Warga',
                      subtitle: 'Kelola data warga',
                      icon: Icons.group_outlined,
                      color: Colors.cyan,
                      onTap: () => context.go('/warga'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 5
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Data Keluarga',
                      subtitle: 'Informasi keluarga',
                      icon: Icons.family_restroom_outlined,
                      color: Colors.pink,
                      onTap: () => context.go('/keluarga'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Dashboard',
                      subtitle: 'Ringkasan data',
                      icon: Icons.dashboard_outlined,
                      color: Colors.indigo,
                      onTap: () {
                        context.go('/dashboard');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 6
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Broadcast Warga',
                      subtitle: 'Kirim pengumuman',
                      icon: Icons.campaign_outlined,
                      color: Colors.deepOrange,
                      onTap: () {
                        context.go('/broadcast-warga');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Daftar Kegiatan',
                      subtitle: 'Lihat kegiatan',
                      icon: Icons.event_outlined,
                      color: Colors.amber,
                      onTap: () {
                        context.go('/kegiatan');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Row 7
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Buat Broadcast',
                      subtitle: 'Broadcast baru',
                      icon: Icons.add_comment_outlined,
                      color: Colors.deepPurple,
                      onTap: () {
                        context.go('/create-broadcast');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Buat Kegiatan',
                      subtitle: 'Kegiatan baru',
                      icon: Icons.event_note_outlined,
                      color: Colors.lightGreen,
                      onTap: () {
                        context.go('/kegiatan/create');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container
        (
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
