// lib/pages/event_list_page.dart
import 'package:flutter/material.dart';
import 'package:jawara/ui/widgets/event_list_content.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // Menjaga item sidebar yang relevan tetap terpilih
  String _selectedMenuItem = 'Kegiatan - Daftar';

  void _onMenuItemSelected(String item) {
    setState(() {
      _selectedMenuItem = item;
      // Di sini Anda bisa menambahkan logika GoRouter.go() untuk navigasi penuh
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Sidebar Navigasi
          
          
          // Konten Utama: Daftar Kegiatan
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
                  child: EventListContent(title: 'Kegiatan - Daftar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}