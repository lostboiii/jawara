import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/broadcast_model.dart';
import 'package:jawara/data/models/kegiatan_model.dart';
import 'package:jawara/data/models/keluarga.dart';
import 'package:jawara/data/models/metode_pembayaran_model.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'package:jawara/data/models/rumah_model.dart';
import 'package:jawara/data/models/warga_model.dart';

void main() {
  group('PengeluaranModel', () {
    test('supports JSON round trip and copyWith', () {
      final source = {
        'id': 'p1',
        'nama_pengeluaran': 'Perbaikan Jalan',
        'tanggal_pengeluaran': '2024-10-01T12:00:00.000Z',
        'kategori_pengeluaran': 'Operasional',
        'jumlah': 1250000,
        'bukti_pengeluaran': 'bukti.png',
      };

      final model = PengeluaranModel.fromJson(source);
      expect(model.id, 'p1');
      expect(model.namaPengeluaran, 'Perbaikan Jalan');
      expect(model.tanggalPengeluaran.toIso8601String(), '2024-10-01T12:00:00.000Z');
      expect(model.toJson()['jumlah'], 1250000);
      expect(model.toPersistenceMap()['nama_pengeluaran'], 'Perbaikan Jalan');

      final copied = model.copyWith(jumlah: 1500000, buktiPengeluaran: 'bukti-baru.png');
      expect(copied.jumlah, 1500000);
      expect(copied.buktiPengeluaran, 'bukti-baru.png');
      expect(copied.id, model.id);
    });
  });

  group('MetodePembayaranModel', () {
    test('serializes optional fields correctly', () {
      final source = {
        'id': 'm1',
        'nama_metode': 'Bank Transfer',
        'nomor_rekening': '1234567890',
        'nama_pemilik': 'Admin RW',
        'foto_barcode': 'barcode.png',
        'thumbnail': 'thumb.png',
        'catatan': 'Hanya menerima jam kerja',
        'inserted_at': '2024-03-01T08:30:00.000Z',
        'updated_at': '2024-03-02T09:45:00.000Z',
      };

      final model = MetodePembayaranModel.fromJson(source);
      expect(model.namaMetode, 'Bank Transfer');
      expect(model.insertedAt?.toIso8601String(), '2024-03-01T08:30:00.000Z');

      final json = model.toJson();
      expect(json['nama_metode'], 'Bank Transfer');
      expect(json['inserted_at'], '2024-03-01T08:30:00.000Z');
      expect(model.toPersistenceMap()['catatan'], 'Hanya menerima jam kerja');

      final copied = model.copyWith(namaMetode: 'QRIS', nomorRekening: '');
      expect(copied.namaMetode, 'QRIS');
      expect(copied.nomorRekening, '');
      expect(copied.id, model.id);
    });
  });

  group('BroadcastModel', () {
    test('serializes and copies data', () {
      final source = {
        'id': 'b1',
        'judul_broadcast': 'Pemeliharaan',
        'isi_broadcast': 'Jadwal pemeliharaan lingkungan',
        'foto_broadcast': 'foto.jpg',
        'dokumen_broadcast': 'dok.pdf',
        'created_at': '2024-05-10T10:00:00.000Z',
        'updated_at': '2024-05-11T10:00:00.000Z',
      };

      final model = BroadcastModel.fromJson(source);
      expect(model.judulBroadcast, 'Pemeliharaan');
      expect(model.createdAt?.toIso8601String(), '2024-05-10T10:00:00.000Z');
      expect(model.toPersistenceMap()['isi_broadcast'], 'Jadwal pemeliharaan lingkungan');

      final copy = model.copyWith(judulBroadcast: 'Update Jadwal', dokumenBroadcast: 'dok-baru.pdf');
      expect(copy.judulBroadcast, 'Update Jadwal');
      expect(copy.dokumenBroadcast, 'dok-baru.pdf');
    });
  });

  group('KegiatanModel', () {
    test('formats date for persistence', () {
      final source = {
        'id': 'k1',
        'nama_kegiatan': 'Kerja Bakti',
        'kategori_kegiatan': 'Lingkungan',
        'tanggal_kegiatan': '2024-09-01',
        'lokasi_kegiatan': 'Balai RW',
        'penanggung_jawab': 'Ketua RT',
        'deskripsi': 'Membersihkan taman',
      };

      final model = KegiatanModel.fromJson(source);
      expect(model.namaKegiatan, 'Kerja Bakti');
      expect(model.tanggalKegiatan?.toIso8601String().startsWith('2024-09-01'), isTrue);
      expect(model.toPersistenceMap()['tanggal_kegiatan'], '2024-09-01');

      final updated = model.copyWith(deskripsi: 'Membersihkan dan menanam pohon');
      expect(updated.deskripsi, 'Membersihkan dan menanam pohon');
    });
  });

  group('Keluarga', () {
    test('supports JSON conversion and copy', () {
      final now = DateTime(2024, 6, 20, 12, 0);
      final model = Keluarga(
        id: 'fam1',
        kepalakeluargaId: 'w1',
        nomorKk: '321321321',
        alamat: 'rumah-1',
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['kepala_keluarga_id'], 'w1');
      expect(json['created_at'], now.toIso8601String());

      final fromJson = Keluarga.fromJson(json);
      expect(fromJson.createdAt, now);

      final copy = model.copyWith(nomorKk: '987654321');
      expect(copy.nomorKk, '987654321');
      expect(copy.id, model.id);
    });
  });

  group('Rumah', () {
    test('serializes numeric fields and round-trip', () {
      final source = {
        'id': 'r1',
        'nomorRumah': 'A1',
        'alamatLengkap': 'Jl. Mawar No. 5',
        'rt': '01',
        'rw': '02',
        'kelurahan': 'Cempaka',
        'kecamatan': 'Cempaka Baru',
        'statusKepemilikan': 'Milik Sendiri',
        'luasTanah': 90,
        'luasBangunan': 72,
        'jumlahPenghuni': 4,
      };

      final rumah = RumahModel.fromJson(source);
      expect(rumah.luasBangunan, 72.0);
      expect(rumah.toJson()['luasBangunan'], 72.0);
      expect(rumah.toJson()['statusKepemilikan'], 'Milik Sendiri');
    });
  });

  group('Warga', () {
    test('converts to and from JSON with dates', () {
      final now = DateTime(2000, 1, 15);
      final warga = Warga(
        id: 'w1',
        nik: '1234567890123456',
        nama: 'Raka',
        jenisKelamin: 'Laki-laki',
        tempatLahir: 'Bandung',
        tanggalLahir: now,
        agama: 'Islam',
        pendidikan: 'S1',
        pekerjaan: 'Programmer',
        statusPerkawinan: 'Belum Kawin',
        noTelepon: '08123456789',
        idRumah: 'r1',
        statusDalamKeluarga: 'Anak',
      );

      final json = warga.toJson();
      expect(json['tanggalLahir'], now.toIso8601String());

      final parsed = Warga.fromJson(json);
      expect(parsed.nama, 'Raka');
      expect(parsed.tanggalLahir, now);
    });
  });
}
