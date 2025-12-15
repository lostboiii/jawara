class KegiatanModel {
  const KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.tanggalKegiatan,
    this.lokasiKegiatan,
    this.penanggungJawab,
    this.deskripsi,
    this.anggaran,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final DateTime? tanggalKegiatan;
  final String? lokasiKegiatan;
  final String? penanggungJawab;
  final String? deskripsi;
  final double? anggaran;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      id: json['id'] as String,
      namaKegiatan: (json['nama_kegiatan'] ?? '') as String,
      kategoriKegiatan: (json['kategori_kegiatan'] ?? '') as String,
      tanggalKegiatan: json['tanggal_kegiatan'] != null
          ? DateTime.tryParse(json['tanggal_kegiatan'].toString())
          : null,
      lokasiKegiatan: json['lokasi_kegiatan'] as String?,
      penanggungJawab: json['penanggung_jawab'] as String?,
      deskripsi: json['deskripsi'] as String?,
      anggaran: json['anggaran'] != null 
          ? double.tryParse(json['anggaran'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kegiatan': namaKegiatan,
      'kategori_kegiatan': kategoriKegiatan,
      'tanggal_kegiatan': tanggalKegiatan?.toIso8601String(),
      'lokasi_kegiatan': lokasiKegiatan,
      'penanggung_jawab': penanggungJawab,
      'deskripsi': deskripsi,
      'anggaran': anggaran,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toPersistenceMap() {
    return {
      'nama_kegiatan': namaKegiatan,
      'kategori_kegiatan': kategoriKegiatan,
      'tanggal_kegiatan': tanggalKegiatan?.toIso8601String().split('T').first,
      'lokasi_kegiatan': lokasiKegiatan,
      'penanggung_jawab': penanggungJawab,
      'deskripsi': deskripsi,
      'anggaran': anggaran,
    };
  }

  KegiatanModel copyWith({
    String? id,
    String? namaKegiatan,
    String? kategoriKegiatan,
    DateTime? tanggalKegiatan,
    String? lokasiKegiatan,
    String? penanggungJawab,
    String? deskripsi,
    double? anggaran,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KegiatanModel(
      id: id ?? this.id,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      kategoriKegiatan: kategoriKegiatan ?? this.kategoriKegiatan,
      tanggalKegiatan: tanggalKegiatan ?? this.tanggalKegiatan,
      lokasiKegiatan: lokasiKegiatan ?? this.lokasiKegiatan,
      penanggungJawab: penanggungJawab ?? this.penanggungJawab,
      deskripsi: deskripsi ?? this.deskripsi,
      anggaran: anggaran ?? this.anggaran,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
