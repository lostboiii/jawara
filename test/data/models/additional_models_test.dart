import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/broadcast_model.dart';
import 'package:jawara/data/models/kegiatan_model.dart';
import 'package:jawara/data/models/pemasukan_model.dart';

void main() {
  group('BroadcastModel Tests', () {
    test('creates BroadcastModel correctly', () {
      final broadcast = BroadcastModel(
        id: 'b1',
        judulBroadcast: 'Pengumuman',
        isiBroadcast: 'Isi pengumuman',
      );

      expect(broadcast.id, 'b1');
      expect(broadcast.judulBroadcast, 'Pengumuman');
      expect(broadcast.isiBroadcast, 'Isi pengumuman');
    });

    test('BroadcastModel toJson works', () {
      final broadcast = BroadcastModel(
        id: 'b1',
        judulBroadcast: 'Test',
        isiBroadcast: 'Content',
      );

      final json = broadcast.toJson();
      expect(json['id'], 'b1');
      expect(json['judul_broadcast'], 'Test');
    });
  });

  group('KegiatanModel Tests', () {
    test('creates KegiatanModel correctly', () {
      final kegiatan = KegiatanModel(
        id: 'k1',
        namaKegiatan: 'Gotong Royong',
        tanggalKegiatan: DateTime(2024, 1, 1),
        kategoriKegiatan: 'Gotong Royong',
        lokasiKegiatan: 'Balai RW',
      );

      expect(kegiatan.id, 'k1');
      expect(kegiatan.namaKegiatan, 'Gotong Royong');
      expect(kegiatan.tanggalKegiatan, DateTime(2024, 1, 1));
    });
  });

  group('PemasukanModel Tests', () {
    test('creates PemasukanModel correctly', () {
      final pemasukan = PemasukanModel(
        id: 'p1',
        nama_pemasukan: 'Iuran Bulanan',
        kategori_pemasukan: 'Iuran',
        jumlah: 100000,
        tanggal_pemasukan: DateTime(2024, 1, 1),
      );

      expect(pemasukan.id, 'p1');
      expect(pemasukan.kategori_pemasukan, 'Iuran');
      expect(pemasukan.jumlah, 100000);
    });

    test('PemasukanModel with bukti', () {
      final pemasukan = PemasukanModel(
        id: 'p1',
        nama_pemasukan: 'Donasi',
        kategori_pemasukan: 'Donasi',
        jumlah: 50000,
        tanggal_pemasukan: DateTime(2024, 1, 1),
        bukti_pemasukan: 'bukti.jpg',
      );

      expect(pemasukan.bukti_pemasukan, 'bukti.jpg');
    });
  });
}
