// lib/pages/create_broadcast_page.dart
import 'package:flutter/material.dart';
import 'package:jawara/widgets/create_broadcast_content.dart                                                                                                                                                                                                                                            ';

class CreateBroadcastPage extends StatefulWidget {
  const CreateBroadcastPage({super.key});

  @override
  State<CreateBroadcastPage> createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage> {
  // Menjaga item sidebar yang relevan tetap terpilih
  String _selectedMenuItem = 'Broadcast - Tambah';

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
        
          
          // Konten Utama: Formulir Buat Broadcast
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
                  child: CreateBroadcastContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}