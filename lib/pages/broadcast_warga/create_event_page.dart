// lib/pages/create_event_page.dart
import 'package:flutter/material.dart';
import 'package:jawara/widgets/create_event_content.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Menjaga item sidebar yang relevan tetap terpilih
  String _selectedMenuItem = 'Kegiatan - Tambah';

  void _onMenuItemSelected(String item) {
    setState(() {
      _selectedMenuItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Sidebar Navigasi
          
          
          // Konten Utama: Formulir Buat Kegiatan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1), 
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CreateEventContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}