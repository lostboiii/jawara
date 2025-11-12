/// Model untuk profil warga
class WargaProfile {
  final String id;
  final String namaLengkap;
  final String nik;
  final String email;
  final String noHp;
  final String jenisKelamin;
  final String agama;
  final String golonganDarah;
  final String pekerjaan;
  final String? fotoIdentitasUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WargaProfile({
    required this.id,
    required this.namaLengkap,
    required this.nik,
    required this.email,
    required this.noHp,
    required this.jenisKelamin,
    required this.agama,
    required this.golonganDarah,
    required this.pekerjaan,
    this.fotoIdentitasUrl,
    this.role = 'warga',
    this.createdAt,
    this.updatedAt,
  });

  /// Konversi dari JSON (dari Supabase)
  factory WargaProfile.fromJson(Map<String, dynamic> json) {
    return WargaProfile(
      id: json['id'] as String? ?? '',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      email: json['email'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      jenisKelamin: json['jenis_kelamin'] as String? ?? '',
      agama: json['agama'] as String? ?? '',
      golonganDarah: json['golongan_darah'] as String? ?? '',
      pekerjaan: json['pekerjaan'] as String? ?? '',
      fotoIdentitasUrl: json['foto_identitas_url'] as String?,
      role: json['role'] as String? ?? 'warga',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Konversi ke JSON (untuk Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'email': email,
      'no_hp': noHp,
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'golongan_darah': golonganDarah,
      'pekerjaan': pekerjaan,
      'foto_identitas_url': fotoIdentitasUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with untuk update partial
  WargaProfile copyWith({
    String? id,
    String? namaLengkap,
    String? nik,
    String? email,
    String? noHp,
    String? jenisKelamin,
    String? agama,
    String? golonganDarah,
    String? pekerjaan,
    String? fotoIdentitasUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WargaProfile(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nik: nik ?? this.nik,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      agama: agama ?? this.agama,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      fotoIdentitasUrl: fotoIdentitasUrl ?? this.fotoIdentitasUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'WargaProfile(id: $id, name: $namaLengkap, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WargaProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
