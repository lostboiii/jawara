class RumahModel {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RumahModel({
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
    this.createdAt,
    this.updatedAt,
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
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory RumahModel.fromJson(Map<String, dynamic> json) {
    return RumahModel(
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
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
