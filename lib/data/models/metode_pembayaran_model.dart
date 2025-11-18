class MetodePembayaranModel {
  const MetodePembayaranModel({
    required this.id,
    required this.namaMetode,
    this.nomorRekening,
    this.namaPemilik,
    this.fotoBarcode,
    this.thumbnail,
    this.catatan,
    this.insertedAt,
    this.updatedAt,
  });

  final String id;
  final String namaMetode;
  final String? nomorRekening;
  final String? namaPemilik;
  final String? fotoBarcode;
  final String? thumbnail;
  final String? catatan;
  final DateTime? insertedAt;
  final DateTime? updatedAt;

  factory MetodePembayaranModel.fromJson(Map<String, dynamic> json) {
    return MetodePembayaranModel(
      id: json['id'] as String,
      namaMetode: (json['nama_metode'] ?? '') as String,
      nomorRekening: json['nomor_rekening'] as String?,
      namaPemilik: json['nama_pemilik'] as String?,
      fotoBarcode: json['foto_barcode'] as String?,
      thumbnail: json['thumbnail'] as String?,
      catatan: json['catatan'] as String?,
      insertedAt: json['inserted_at'] != null
          ? DateTime.tryParse(json['inserted_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_metode': namaMetode,
      'nomor_rekening': nomorRekening,
      'nama_pemilik': namaPemilik,
      'foto_barcode': fotoBarcode,
      'thumbnail': thumbnail,
      'catatan': catatan,
      if (insertedAt != null) 'inserted_at': insertedAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toPersistenceMap() {
    return {
      'nama_metode': namaMetode,
      'nomor_rekening': nomorRekening,
      'nama_pemilik': namaPemilik,
      'foto_barcode': fotoBarcode,
      'thumbnail': thumbnail,
      'catatan': catatan,
    };
  }

  MetodePembayaranModel copyWith({
    String? id,
    String? namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
    DateTime? insertedAt,
    DateTime? updatedAt,
  }) {
    return MetodePembayaranModel(
      id: id ?? this.id,
      namaMetode: namaMetode ?? this.namaMetode,
      nomorRekening: nomorRekening ?? this.nomorRekening,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      fotoBarcode: fotoBarcode ?? this.fotoBarcode,
      thumbnail: thumbnail ?? this.thumbnail,
      catatan: catatan ?? this.catatan,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
