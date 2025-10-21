import 'package:flutter/material.dart';

class KeluargaPage extends StatelessWidget {
  const KeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Keluarga")),
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
