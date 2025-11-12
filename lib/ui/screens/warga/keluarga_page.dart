import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KeluargaPage extends StatelessWidget {
  const KeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Data Keluarga", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        children: const [
          ListTile(title: Text("Kepala Keluarga: Budi Santoso")),
          ListTile(title: Text("Istri: Siti Aminah")),
          ListTile(title: Text("Anak 1: Andi")),
          ListTile(title: Text("Anak 2: Rina")),
        ],
      ),
    );
  }
}
