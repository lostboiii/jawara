// lib/widgets/list_layout_helpers.dart
import 'package:flutter/material.dart';

// Widget yang dapat digunakan kembali untuk Header Konten Daftar
class ListHeader extends StatelessWidget {
  final String title;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  const ListHeader(this.title, {this.showAddButton = false, this.onAddPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (showAddButton)
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text('Tambah', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E35B1), 
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
            ),
        ],
      ),
    );
  }
}

// Widget yang dapat digunakan kembali untuk Paginasi
class ListPagination extends StatelessWidget {
  const ListPagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), 
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)), 
            child: const Text('1', style: TextStyle(color: Colors.white))
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios)),
        ],
      ),
    );
  }
}