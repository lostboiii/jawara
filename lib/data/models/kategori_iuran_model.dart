class KategoriIuranModel {
  final String id;
  final String namaIuran;
  final String kategoriIuran;

  KategoriIuranModel({
    required this.id,
    required this.namaIuran,
    required this.kategoriIuran,
  });

  factory KategoriIuranModel.fromJson(Map<String, dynamic> json) {
    return KategoriIuranModel(
      id: json['id'],
      namaIuran: json['nama_iuran'],
      kategoriIuran: json['kategori_iuran'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_iuran': namaIuran,
      'kategori_iuran': kategoriIuran,
    };
  }
}
