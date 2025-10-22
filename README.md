# jawara

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Fitur Aplikasi

Aplikasi ini adalah sistem manajemen dengan desain mobile-friendly.

### Struktur Halaman

- **Home Page** (`lib/pages/home_page.dart`) - Halaman utama dengan menu navigasi
- **Activity Log Page** (`lib/pages/activity_log_page.dart`) - Halaman log aktivitas lengkap
- **Models** (`lib/models/activity_log.dart`) - Model data untuk log aktivitas
- **Router** (`lib/router/app_router.dart`) - Konfigurasi routing dengan go_router

### Fitur Home Page
- **Welcome Screen**: Landing page dengan greeting dan menu navigasi
- **Menu Cards**: 3 menu utama dengan icon dan deskripsi
  - Log Aktivitas - Menuju halaman riwayat aktivitas
  - Dashboard - Coming soon
  - Pengaturan - Coming soon
- **Mobile Padding**: Design dengan padding 16px untuk kerapian di mobile
- **Responsive Layout**: SafeArea dan proper spacing

### Fitur Activity Log Page
- **List View**: Menampilkan daftar aktivitas dengan nomor, deskripsi, aktor, dan tanggal
- **Header**: Kolom NO dan DESKRIPSI untuk kemudahan membaca
- **Card Design**: Setiap item dalam card dengan shadow dan rounded corners
- **Info Detail**: Icon person untuk aktor dan calendar untuk tanggal
- **Filter Button**: Tombol filter di app bar (siap untuk implementasi)
- **Pagination**: Navigasi halaman dengan tombol prev/next dan nomor halaman (10 items per page)
- **Mobile Optimized**: Padding 8px horizontal, card spacing, dan SafeArea

### Routing
- `/` - Home Page (landing page dengan menu)
- `/activity-log` - Activity Log Page (daftar log aktivitas)

### Menjalankan Aplikasi

```bash
flutter run
```

### Menjalankan Tests

```bash
flutter test
```

Semua test harus PASS:
- Home page renders correctly
- Navigate to Activity Log page
