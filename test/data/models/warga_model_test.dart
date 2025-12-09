import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/warga_model.dart';

void main() {
  group('Warga Model Tests', () {
    test('fromJson creates Warga correctly', () {
      final json = {
        'id': 'w1',
        'nik': '1234567890',
        'nama': 'John Doe',
        'jenisKelamin': 'Laki-laki',
        'tempatLahir': 'Jakarta',
        'tanggalLahir': '1990-01-01T00:00:00.000Z',
        'agama': 'Islam',
        'pendidikan': 'S1',
        'pekerjaan': 'Karyawan',
        'statusPerkawinan': 'Menikah',
        'noTelepon': '08123456789',
        'idRumah': 'r1',
        'statusDalamKeluarga': 'Kepala Keluarga',
      };

      final warga = Warga.fromJson(json);

      expect(warga.id, 'w1');
      expect(warga.nik, '1234567890');
      expect(warga.nama, 'John Doe');
      expect(warga.jenisKelamin, 'Laki-laki');
      expect(warga.tempatLahir, 'Jakarta');
      expect(warga.tanggalLahir, DateTime.parse('1990-01-01T00:00:00.000Z'));
      expect(warga.agama, 'Islam');
      expect(warga.pendidikan, 'S1');
      expect(warga.pekerjaan, 'Karyawan');
      expect(warga.statusPerkawinan, 'Menikah');
      expect(warga.noTelepon, '08123456789');
      expect(warga.idRumah, 'r1');
      expect(warga.statusDalamKeluarga, 'Kepala Keluarga');
    });

    test('toJson converts Warga to Map correctly', () {
      final warga = Warga(
        id: 'w1',
        nik: '1234567890',
        nama: 'John Doe',
        jenisKelamin: 'Laki-laki',
        tempatLahir: 'Jakarta',
        tanggalLahir: DateTime.parse('1990-01-01T00:00:00.000Z'),
        agama: 'Islam',
        pendidikan: 'S1',
        pekerjaan: 'Karyawan',
        statusPerkawinan: 'Menikah',
        noTelepon: '08123456789',
        idRumah: 'r1',
        statusDalamKeluarga: 'Kepala Keluarga',
      );

      final json = warga.toJson();

      expect(json['id'], 'w1');
      expect(json['nik'], '1234567890');
      expect(json['nama'], 'John Doe');
      expect(json['jenisKelamin'], 'Laki-laki');
      expect(json['tempatLahir'], 'Jakarta');
      expect(json['tanggalLahir'], '1990-01-01T00:00:00.000Z');
      expect(json['agama'], 'Islam');
      expect(json['pendidikan'], 'S1');
      expect(json['pekerjaan'], 'Karyawan');
      expect(json['statusPerkawinan'], 'Menikah');
      expect(json['noTelepon'], '08123456789');
      expect(json['idRumah'], 'r1');
      expect(json['statusDalamKeluarga'], 'Kepala Keluarga');
    });

    test('fromJson and toJson are inverse operations', () {
      final json = {
        'id': 'w2',
        'nik': '9876543210',
        'nama': 'Jane Smith',
        'jenisKelamin': 'Perempuan',
        'tempatLahir': 'Bandung',
        'tanggalLahir': '1995-05-15T00:00:00.000Z',
        'agama': 'Kristen',
        'pendidikan': 'SMA',
        'pekerjaan': 'Guru',
        'statusPerkawinan': 'Belum Menikah',
        'noTelepon': '08987654321',
        'idRumah': 'r2',
        'statusDalamKeluarga': 'Anak',
      };

      final warga = Warga.fromJson(json);
      final jsonOutput = warga.toJson();

      expect(jsonOutput['id'], json['id']);
      expect(jsonOutput['nik'], json['nik']);
      expect(jsonOutput['nama'], json['nama']);
    });
  });

  group('Rumah Model Tests', () {
    test('fromJson creates Rumah correctly', () {
      final json = {
        'id': 'r1',
        'nomor_rumah': '123',
        'alamat': 'Jl. Test',
        'rt': '001',
        'rw': '002',
        'status_kepemilikan': 'Milik Sendiri',
        'jumlah_penghuni': 4,
        'luas_tanah': 100.0,
        'luas_bangunan': 80.0,
        'status_rumah': 'Ditempati',
      };

      final rumah = Rumah.fromJson(json);

      expect(rumah.id, 'r1');
      expect(rumah.nomorRumah, '123');
      expect(rumah.alamat, 'Jl. Test');
      expect(rumah.rt, '001');
      expect(rumah.rw, '002');
      expect(rumah.statusKepemilikan, 'Milik Sendiri');
      expect(rumah.jumlahPenghuni, 4);
      expect(rumah.luasTanah, 100.0);
      expect(rumah.luasBangunan, 80.0);
      expect(rumah.statusRumah, 'Ditempati');
    });

    test('toJson converts Rumah to Map correctly', () {
      final rumah = Rumah(
        id: 'r1',
        nomorRumah: '123',
        alamat: 'Jl. Test',
        rt: '001',
        rw: '002',
        statusKepemilikan: 'Milik Sendiri',
        jumlahPenghuni: 4,
        luasTanah: 100.0,
        luasBangunan: 80.0,
        statusRumah: 'Ditempati',
      );

      final json = rumah.toJson();

      expect(json['id'], 'r1');
      expect(json['nomor_rumah'], '123');
      expect(json['alamat'], 'Jl. Test');
      expect(json['rt'], '001');
      expect(json['rw'], '002');
      expect(json['status_kepemilikan'], 'Milik Sendiri');
      expect(json['jumlah_penghuni'], 4);
      expect(json['luas_tanah'], 100.0);
      expect(json['luas_bangunan'], 80.0);
      expect(json['status_rumah'], 'Ditempati');
    });
  });
}
