// lib/widgets/content/create_broadcast_content.dart
import 'package:flutter/material.dart';

class CreateBroadcastContent extends StatelessWidget {
  const CreateBroadcastContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Buat Broadcast Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 20),

          // Judul Broadcast
          _buildFormLabel('Judul Broadcast'),
          const TextField(decoration: InputDecoration(hintText: 'Masukkan judul broadcast', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          // Isi Broadcast
          _buildFormLabel('Isi Broadcast'),
          const TextField(maxLines: 6, decoration: InputDecoration(hintText: 'Tulis isi broadcast di sini...', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          // Foto Upload
          _buildUploadField('Foto', 'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar.', 'Upload foto png/jpg', 100),
          const SizedBox(height: 20),

          // Dokumen Upload
          _buildUploadField('Dokumen', 'Maksimal 10 file (.pdf), ukuran maksimal 5MB per file.', 'Upload dokumen pdf', 70),
          const SizedBox(height: 30),

          // Tombol Aksi
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

  Widget _buildUploadField(String title, String subtitle, String hint, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(title),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file, color: Colors.grey),
                Text(hint, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}