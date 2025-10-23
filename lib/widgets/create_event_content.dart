// lib/widgets/content/create_event_content.dart
import 'package:flutter/material.dart';

class CreateEventContent extends StatelessWidget {
  const CreateEventContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Buat Kegiatan Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 20),

          _buildFormLabel('Nama Kegiatan'),
          const TextField(decoration: InputDecoration(hintText: 'Contoh: Musyawarah Warga', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          _buildFormLabel('Kategori Kegiatan'),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
            hint: const Text('-- Pilih Kategori --'),
            items: const [],
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),

          _buildFormLabel('Tanggal'),
          const TextField(decoration: InputDecoration(hintText: '--/--/----', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          _buildFormLabel('Lokasi'),
          const TextField(decoration: InputDecoration(hintText: 'Contoh: Bala RT 03', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          _buildFormLabel('Penanggung Jawab'),
          const TextField(decoration: InputDecoration(hintText: 'Contoh: Pak RT atau Bu RW', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          _buildFormLabel('Deskripsi'),
          const TextField(maxLines: 6, decoration: InputDecoration(hintText: 'Tuliskan detail event seperti agenda, keperluan, dll.', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 30),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)), child: const Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}