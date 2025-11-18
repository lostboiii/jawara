import 'package:flutter/material.dart';

/// Legacy placeholder. The kegiatan creation flow kini tersedia di
/// `lib/ui/pages/kegiatan/create_kegiatan_page.dart`.
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('CreateEventPage is deprecated. Gunakan CreateKegiatanPage.'),
      ),
    );
  }
}