import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/metode_pembayaran_model.dart';

void main() {
  group('MetodePembayaranModel Tests', () {
    test('fromJson creates MetodePembayaranModel correctly', () {
      final json = {
        'id': 'm1',
        'nama_metode': 'BCA',
        'nomor_rekening': '1234567890',
        'nama_pemilik': 'John Doe',
        'foto_barcode': 'barcode.jpg',
        'thumbnail': 'thumb.jpg',
        'catatan': 'Test catatan',
        'inserted_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final metode = MetodePembayaranModel.fromJson(json);

      expect(metode.id, 'm1');
      expect(metode.namaMetode, 'BCA');
      expect(metode.nomorRekening, '1234567890');
      expect(metode.namaPemilik, 'John Doe');
      expect(metode.fotoBarcode, 'barcode.jpg');
      expect(metode.thumbnail, 'thumb.jpg');
      expect(metode.catatan, 'Test catatan');
      expect(metode.insertedAt, isNotNull);
      expect(metode.updatedAt, isNotNull);
    });

    test('toJson converts MetodePembayaranModel correctly', () {
      final metode = MetodePembayaranModel(
        id: 'm1',
        namaMetode: 'BCA',
        nomorRekening: '1234567890',
        namaPemilik: 'John Doe',
        fotoBarcode: 'barcode.jpg',
        thumbnail: 'thumb.jpg',
        catatan: 'Test catatan',
        insertedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = metode.toJson();

      expect(json['id'], 'm1');
      expect(json['nama_metode'], 'BCA');
      expect(json['nomor_rekening'], '1234567890');
      expect(json['nama_pemilik'], 'John Doe');
      expect(json['foto_barcode'], 'barcode.jpg');
      expect(json['thumbnail'], 'thumb.jpg');
      expect(json['catatan'], 'Test catatan');
    });

    test('copyWith creates new instance with updated values', () {
      final original = MetodePembayaranModel(
        id: 'm1',
        namaMetode: 'BCA',
        nomorRekening: '1234567890',
        namaPemilik: 'John Doe',
      );

      final updated = original.copyWith(
        namaMetode: 'Mandiri',
        nomorRekening: '9876543210',
      );

      expect(updated.id, 'm1');
      expect(updated.namaMetode, 'Mandiri');
      expect(updated.nomorRekening, '9876543210');
      expect(updated.namaPemilik, 'John Doe');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'm1',
        'nama_metode': 'BCA',
        'nomor_rekening': null,
        'nama_pemilik': null,
        'foto_barcode': null,
        'thumbnail': null,
        'catatan': null,
        'inserted_at': null,
        'updated_at': null,
      };

      final metode = MetodePembayaranModel.fromJson(json);

      expect(metode.id, 'm1');
      expect(metode.namaMetode, 'BCA');
      expect(metode.nomorRekening, isNull);
      expect(metode.namaPemilik, isNull);
      expect(metode.fotoBarcode, isNull);
      expect(metode.thumbnail, isNull);
      expect(metode.catatan, isNull);
      expect(metode.insertedAt, isNull);
      expect(metode.updatedAt, isNull);
    });

    test('toPersistenceMap excludes id and timestamps', () {
      final metode = MetodePembayaranModel(
        id: 'm1',
        namaMetode: 'BCA',
        nomorRekening: '1234567890',
        namaPemilik: 'John Doe',
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = metode.toPersistenceMap();

      expect(map.containsKey('id'), false);
      expect(map.containsKey('inserted_at'), false);
      expect(map.containsKey('updated_at'), false);
      expect(map['nama_metode'], 'BCA');
      expect(map['nomor_rekening'], '1234567890');
      expect(map['nama_pemilik'], 'John Doe');
    });
  });
}
