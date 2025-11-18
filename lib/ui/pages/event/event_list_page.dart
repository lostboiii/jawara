import 'package:flutter/material.dart';

/// Legacy placeholder. The kegiatan feature has been migrated to the
/// Supabase-backed implementation in `lib/ui/pages/kegiatan`.
class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('EventListPage is deprecated. Gunakan KegiatanListPage.'),
      ),
    );
  }
}
