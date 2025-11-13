class Keluarga {
  final String? id;
  final String kepalakeluargaId;
  final String nomorKk;
  final String alamat; // UUID reference to rumah
  final DateTime? createdAt;

  Keluarga({
    this.id,
    required this.kepalakeluargaId,
    required this.nomorKk,
    required this.alamat,
    this.createdAt,
  });

  /// Convert from JSON
  factory Keluarga.fromJson(Map<String, dynamic> json) {
    return Keluarga(
      id: json['id'] as String?,
      kepalakeluargaId: json['kepala_keluarga_id'] as String? ?? '',
      nomorKk: json['nomor_kk'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kepala_keluarga_id': kepalakeluargaId,
      'nomor_kk': nomorKk,
      'alamat': alamat,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Copy with
  Keluarga copyWith({
    String? id,
    String? kepalakeluargaId,
    String? nomorKk,
    String? alamat,
    DateTime? createdAt,
  }) {
    return Keluarga(
      id: id ?? this.id,
      kepalakeluargaId: kepalakeluargaId ?? this.kepalakeluargaId,
      nomorKk: nomorKk ?? this.nomorKk,
      alamat: alamat ?? this.alamat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
