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
  final String? id;
  final String nomorRumah;
  final String alamat;
  final String rt;
  final String rw;
  final String statusKepemilikan;
  final int jumlahPenghuni;
  final double luasTanah;
  final double luasBangunan;
  final String statusRumah;

  Rumah({
    this.id,
    required this.nomorRumah,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.statusKepemilikan,
    required this.jumlahPenghuni,
    required this.luasTanah,
    required this.luasBangunan,
    required this.statusRumah,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomor_rumah': nomorRumah,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'status_kepemilikan': statusKepemilikan,
      'jumlah_penghuni': jumlahPenghuni,
      'luas_tanah': luasTanah,
      'luas_bangunan': luasBangunan,
      'status_rumah': statusRumah,
    };
  }

  factory Rumah.fromJson(Map<String, dynamic> json) {
    return Rumah(
      id: json['id'] as String?,
      nomorRumah: json['nomor_rumah'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      rt: json['rt'] as String? ?? '',
      rw: json['rw'] as String? ?? '',
      statusKepemilikan: json['status_kepemilikan'] as String? ?? '',
      jumlahPenghuni: json['jumlah_penghuni'] as int? ?? 0,
      luasTanah: (json['luas_tanah'] as num?)?.toDouble() ?? 0.0,
      luasBangunan: (json['luas_bangunan'] as num?)?.toDouble() ?? 0.0,
      statusRumah: json['status_rumah'] as String? ?? 'kosong',
    );
  }

  Rumah copyWith({
    String? id,
    String? nomorRumah,
    String? alamat,
    String? rt,
    String? rw,
    String? statusKepemilikan,
    int? jumlahPenghuni,
    double? luasTanah,
    double? luasBangunan,
    String? statusRumah,
  }) {
    return Rumah(
      id: id ?? this.id,
      nomorRumah: nomorRumah ?? this.nomorRumah,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      statusKepemilikan: statusKepemilikan ?? this.statusKepemilikan,
      jumlahPenghuni: jumlahPenghuni ?? this.jumlahPenghuni,
      luasTanah: luasTanah ?? this.luasTanah,
      luasBangunan: luasBangunan ?? this.luasBangunan,
      statusRumah: statusRumah ?? this.statusRumah,
    );
  }
}
