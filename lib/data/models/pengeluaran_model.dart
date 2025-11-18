class PengeluaranModel {
  const PengeluaranModel({
    required this.id,
    required this.namaPengeluaran,
    required this.tanggalPengeluaran,
    required this.kategoriPengeluaran,
    required this.jumlah,
    this.buktiPengeluaran,
  });

  final String id;
  final String namaPengeluaran;
  final DateTime tanggalPengeluaran;
  final String kategoriPengeluaran;
  final double jumlah;
  final String? buktiPengeluaran;

  factory PengeluaranModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranModel(
      id: json['id'] as String,
      namaPengeluaran: (json['nama_pengeluaran'] ?? '') as String,
      tanggalPengeluaran: DateTime.parse(json['tanggal_pengeluaran'] as String),
      kategoriPengeluaran: (json['kategori_pengeluaran'] ?? '') as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      buktiPengeluaran: json['bukti_pengeluaran'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pengeluaran': namaPengeluaran,
      'tanggal_pengeluaran': tanggalPengeluaran.toIso8601String(),
      'kategori_pengeluaran': kategoriPengeluaran,
      'jumlah': jumlah,
      'bukti_pengeluaran': buktiPengeluaran,
    };
  }

  Map<String, dynamic> toPersistenceMap() {
    return {
      'nama_pengeluaran': namaPengeluaran,
      'tanggal_pengeluaran': tanggalPengeluaran.toIso8601String(),
      'kategori_pengeluaran': kategoriPengeluaran,
      'jumlah': jumlah,
      'bukti_pengeluaran': buktiPengeluaran,
    };
  }

  PengeluaranModel copyWith({
    String? id,
    String? namaPengeluaran,
    DateTime? tanggalPengeluaran,
    String? kategoriPengeluaran,
    double? jumlah,
    String? buktiPengeluaran,
  }) {
    return PengeluaranModel(
      id: id ?? this.id,
      namaPengeluaran: namaPengeluaran ?? this.namaPengeluaran,
      tanggalPengeluaran: tanggalPengeluaran ?? this.tanggalPengeluaran,
      kategoriPengeluaran: kategoriPengeluaran ?? this.kategoriPengeluaran,
      jumlah: jumlah ?? this.jumlah,
      buktiPengeluaran: buktiPengeluaran ?? this.buktiPengeluaran,
    );
  }

}
