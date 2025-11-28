class MutasiModel {
  final String keluarga;
  final String rumah;
  final DateTime tanggal_mutasi;
  final String alasan_mutasi;

  MutasiModel({
    required this.keluarga,
    required this.rumah,
    required this.tanggal_mutasi,
    required this.alasan_mutasi,
  });
  factory MutasiModel.fromJson(Map<String, dynamic> json) {
    return MutasiModel(
      keluarga: (json['keluarga'] ?? '') as String,
      rumah: (json['rumah'] ?? '') as String,
      tanggal_mutasi: json['tanggal_mutasi'] != null
          ? DateTime.tryParse(json['tanggal_mutasi'].toString()) ?? DateTime.now()
          : DateTime.now(),
      alasan_mutasi: (json['alasan_mutasi'] ?? '') as String,
    );
  }  
  Map<String, dynamic> toJson() {
    return {
      'keluarga': keluarga,
      'rumah': rumah,
      'tanggal_mutasi': tanggal_mutasi.toIso8601String(),
      'alasan_mutasi': alasan_mutasi,
    };
  }
  Map<String, dynamic> toPersistenceMap() {
    return {
      'keluarga': keluarga,
      'rumah': rumah,
      'tanggal_mutasi': tanggal_mutasi.toIso8601String(),
      'alasan_mutasi': alasan_mutasi,
    };
  }
  MutasiModel copyWith({
    String? keluarga,
    String? rumah,
    DateTime? tanggal_mutasi,
    String? alasan_mutasi,
  }) {
    return MutasiModel(
      keluarga: keluarga ?? this.keluarga,
      rumah: rumah ?? this.rumah,
      tanggal_mutasi: tanggal_mutasi ?? this.tanggal_mutasi,
      alasan_mutasi: alasan_mutasi ?? this.alasan_mutasi,
    );
  }
}