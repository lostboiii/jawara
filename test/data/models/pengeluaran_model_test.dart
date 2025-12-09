import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';

void main() {
  group('PengeluaranModel Tests', () {
    test('fromJson creates PengeluaranModel correctly', () {
      final json = {
        'id': 'p1',
        'nama_pengeluaran': 'Listrik',
        'tanggal_pengeluaran': '2024-01-01T00:00:00.000Z',
        'kategori_pengeluaran': 'Utilitas',
        'jumlah': 500000.0,
        'bukti_pengeluaran': 'bukti.jpg',
      };

      final pengeluaran = PengeluaranModel.fromJson(json);

      expect(pengeluaran.id, 'p1');
      expect(pengeluaran.namaPengeluaran, 'Listrik');
      expect(pengeluaran.tanggalPengeluaran, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(pengeluaran.kategoriPengeluaran, 'Utilitas');
      expect(pengeluaran.jumlah, 500000.0);
      expect(pengeluaran.buktiPengeluaran, 'bukti.jpg');
    });

    test('toJson converts PengeluaranModel correctly', () {
      final pengeluaran = PengeluaranModel(
        id: 'p1',
        namaPengeluaran: 'Listrik',
        tanggalPengeluaran: DateTime.parse('2024-01-01T00:00:00.000Z'),
        kategoriPengeluaran: 'Utilitas',
        jumlah: 500000.0,
        buktiPengeluaran: 'bukti.jpg',
      );

      final json = pengeluaran.toJson();

      expect(json['id'], 'p1');
      expect(json['nama_pengeluaran'], 'Listrik');
      expect(json['tanggal_pengeluaran'], '2024-01-01T00:00:00.000Z');
      expect(json['kategori_pengeluaran'], 'Utilitas');
      expect(json['jumlah'], 500000.0);
      expect(json['bukti_pengeluaran'], 'bukti.jpg');
    });

    test('toPersistenceMap excludes id', () {
      final pengeluaran = PengeluaranModel(
        id: 'p1',
        namaPengeluaran: 'Listrik',
        tanggalPengeluaran: DateTime.parse('2024-01-01T00:00:00.000Z'),
        kategoriPengeluaran: 'Utilitas',
        jumlah: 500000.0,
      );

      final map = pengeluaran.toPersistenceMap();

      expect(map.containsKey('id'), false);
      expect(map['nama_pengeluaran'], 'Listrik');
      expect(map['tanggal_pengeluaran'], '2024-01-01T00:00:00.000Z');
      expect(map['kategori_pengeluaran'], 'Utilitas');
      expect(map['jumlah'], 500000.0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = PengeluaranModel(
        id: 'p1',
        namaPengeluaran: 'Listrik',
        tanggalPengeluaran: DateTime.parse('2024-01-01T00:00:00.000Z'),
        kategoriPengeluaran: 'Utilitas',
        jumlah: 500000.0,
      );

      final updated = original.copyWith(
        namaPengeluaran: 'Air',
        jumlah: 300000.0,
      );

      expect(updated.id, 'p1');
      expect(updated.namaPengeluaran, 'Air');
      expect(updated.jumlah, 300000.0);
      expect(updated.kategoriPengeluaran, 'Utilitas');
      expect(updated.tanggalPengeluaran, original.tanggalPengeluaran);
    });

    test('fromJson handles null bukti_pengeluaran', () {
      final json = {
        'id': 'p1',
        'nama_pengeluaran': 'Listrik',
        'tanggal_pengeluaran': '2024-01-01T00:00:00.000Z',
        'kategori_pengeluaran': 'Utilitas',
        'jumlah': 500000.0,
        'bukti_pengeluaran': null,
      };

      final pengeluaran = PengeluaranModel.fromJson(json);

      expect(pengeluaran.buktiPengeluaran, isNull);
    });
  });
}
