// lib/models/warga_model.dart
class Warga {
  final String id;
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String agama;
  final String pendidikan;
  final String pekerjaan;
  final String statusPerkawinan;
  final String noTelepon;
  final String idRumah;
  final String statusDalamKeluarga; // Kepala Keluarga, Istri, Anak, dll

  Warga({
    required this.id,
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.agama,
    required this.pendidikan,
    required this.pekerjaan,
    required this.statusPerkawinan,
    required this.noTelepon,
    required this.idRumah,
    required this.statusDalamKeluarga,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'nama': nama,
      'jenisKelamin': jenisKelamin,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'agama': agama,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan,
      'statusPerkawinan': statusPerkawinan,
      'noTelepon': noTelepon,
      'idRumah': idRumah,
      'statusDalamKeluarga': statusDalamKeluarga,
    };
  }

  factory Warga.fromJson(Map<String, dynamic> json) {
    return Warga(
      id: json['id'],
      nik: json['nik'],
      nama: json['nama'],
      jenisKelamin: json['jenisKelamin'],
      tempatLahir: json['tempatLahir'],
      tanggalLahir: DateTime.parse(json['tanggalLahir']),
      agama: json['agama'],
      pendidikan: json['pendidikan'],
      pekerjaan: json['pekerjaan'],
      statusPerkawinan: json['statusPerkawinan'],
      noTelepon: json['noTelepon'],
      idRumah: json['idRumah'],
      statusDalamKeluarga: json['statusDalamKeluarga'],
    );
  }
}

// lib/models/rumah_model.dart
class Rumah {
  final String id;
  final String nomorRumah;
  final String alamatLengkap;
  final String rt;
  final String rw;
  final String kelurahan;
  final String kecamatan;
  final String statusKepemilikan; // Milik Sendiri, Sewa, Kontrak
  final double luasTanah;
  final double luasBangunan;
  final int jumlahPenghuni;

  Rumah({
    required this.id,
    required this.nomorRumah,
    required this.alamatLengkap,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.kecamatan,
    required this.statusKepemilikan,
    required this.luasTanah,
    required this.luasBangunan,
    required this.jumlahPenghuni,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomorRumah': nomorRumah,
      'alamatLengkap': alamatLengkap,
      'rt': rt,
      'rw': rw,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      'statusKepemilikan': statusKepemilikan,
      'luasTanah': luasTanah,
      'luasBangunan': luasBangunan,
      'jumlahPenghuni': jumlahPenghuni,
    };
  }

  factory Rumah.fromJson(Map<String, dynamic> json) {
    return Rumah(
      id: json['id'],
      nomorRumah: json['nomorRumah'],
      alamatLengkap: json['alamatLengkap'],
      rt: json['rt'],
      rw: json['rw'],
      kelurahan: json['kelurahan'],
      kecamatan: json['kecamatan'],
      statusKepemilikan: json['statusKepemilikan'],
      luasTanah: json['luasTanah'].toDouble(),
      luasBangunan: json['luasBangunan'].toDouble(),
      jumlahPenghuni: json['jumlahPenghuni'],
    );
  }
}