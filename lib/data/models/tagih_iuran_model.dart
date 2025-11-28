class TagihIuranModel {
  final String id;
  final DateTime tanggalTagihan;
  final double jumlah;
  final String statusTagihan;
  final DateTime? tanggalBayar;
  final String? buktiBayar;
  final String kategoriId;

  TagihIuranModel({
    required this.id,
    required this.tanggalTagihan,
    required this.jumlah,
    required this.statusTagihan,
    required this.kategoriId,
    this.tanggalBayar,
    this.buktiBayar,
  });

  factory TagihIuranModel.fromJson(Map<String, dynamic> json) {
    return TagihIuranModel(
      id: json['id'],
      tanggalTagihan: DateTime.parse(json['tanggal_tagihan']),
      jumlah: double.parse(json['jumlah'].toString()),
      statusTagihan: json['status_tagihan'],
      tanggalBayar: json['tanggal_bayar'] != null
          ? DateTime.parse(json['tanggal_bayar'])
          : null,
      buktiBayar: json['bukti_bayar'],
      kategoriId: json['kategori_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_tagihan': tanggalTagihan.toIso8601String(),
      'jumlah': jumlah,
      'status_tagihan': statusTagihan,
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'bukti_bayar': buktiBayar,
      'kategori_id': kategoriId,
    };
  }
}
