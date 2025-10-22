import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'channel_item.dart';
import 'channel_transfer_detail_page.dart';

class ChannelTransferPage extends StatefulWidget {
  const ChannelTransferPage({super.key});

  @override
  State<ChannelTransferPage> createState() => _ChannelTransferPageState();
}

class _ChannelTransferPageState extends State<ChannelTransferPage> {
  // Note: Add/Edit handled in ChannelTransferDetailPage
  final List<ChannelItem> _channels = [
    ChannelItem(
      nama: 'QRIS Resmi RT 08',
      tipe: 'qris',
      nomor: '-',
      an: 'RW 08 Karangploso',
      thumbnailPath: null,
    ),
    ChannelItem(
      nama: 'BCA',
      tipe: 'bank',
      nomor: '00000000',
      an: 'jose',
      thumbnailPath: null,
    ),
    ChannelItem(
      nama: '234234',
      tipe: 'ewallet',
      nomor: '23234',
      an: '-',
      thumbnailPath: null,
    ),
    ChannelItem(
      nama: 'Transfer via BCA',
      tipe: 'bank',
      nomor: '-',
      an: 'RT Jawara Karangploso',
      thumbnailPath: null,
    ),
  ];

  Color _typeBg(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'bank':
        return Colors.blue.shade100;
      case 'ewallet':
        return Colors.purple.shade100;
      case 'qris':
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _typeFg(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'bank':
        return Colors.blue.shade900;
      case 'ewallet':
        return Colors.purple.shade900;
      case 'qris':
        return Colors.teal.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _kvRow(String label, String value) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbWidget(String? path) {
    if (path == null) return const SizedBox.shrink();
    if (kIsWeb) return const Icon(Icons.image, size: 32);
    final f = File(path);
    if (!f.existsSync()) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(f, width: 56, height: 56, fit: BoxFit.cover),
    );
  }

  Future<void> _openDetail({ChannelItem? item, int? index}) async {
    final result = await Navigator.push<ChannelItem>(
      context,
      MaterialPageRoute(builder: (_) => ChannelTransferDetailPage(item: item)),
    );
    if (result != null) {
      setState(() {
        if (index == null) {
          _channels.add(result);
        } else {
          _channels[index] = result;
        }
      });
    }
  }

  Widget _channelCard(ChannelItem c, int index) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Channel',
                        style: t.labelLarge?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.nama,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (c.thumbnailPath != null) _thumbWidget(c.thumbnailPath),
                const SizedBox(width: 8),
                Chip(
                  label: Text(c.tipe),
                  backgroundColor: _typeBg(c.tipe),
                  labelStyle: t.labelMedium?.copyWith(color: _typeFg(c.tipe)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('A/N', c.an),
            const Divider(height: 1),
            _kvRow('Nomor', c.nomor),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _openDetail(item: c, index: index),
                  child: const Text('Lihat Detail'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _channels.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.icon(
                  onPressed: () => _openDetail(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _channels.length,
                itemBuilder: (context, i) => _channelCard(_channels[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
