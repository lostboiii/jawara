import 'package:flutter/foundation.dart';

class PemasukanModel {
  final String id;
  final String nama_pemasukan;
  final DateTime tanggal_pemasukan;
  final String kategori_pemasukan;
  final double jumlah;
  final String? bukti_pemasukan;
  final DateTime? verifiedAt;
  final String? verifier;

  const PemasukanModel({
    required this.id,
    required this.nama_pemasukan,
    required this.tanggal_pemasukan,
    required this.kategori_pemasukan,
    required this.jumlah,
    this.bukti_pemasukan,
    this.verifiedAt,
    this.verifier,
  });

  factory PemasukanModel.fromJson(Map<String, dynamic> json) {
    return PemasukanModel(
      id: json['id'] as String,
      nama_pemasukan: (json['nama_pemasukan'] ?? '') as String,
      tanggal_pemasukan: DateTime.parse(json['tanggal_pemasukan'] as String),
      kategori_pemasukan: (json['kategori_pemasukan'] ?? '') as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      bukti_pemasukan: json['bukti_pemasukan'] as String?,
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      verifier: json['verifier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pemasukan': nama_pemasukan,
      'tanggal_pemasukan': tanggal_pemasukan.toIso8601String(),
      'kategori_pemasukan': kategori_pemasukan,
      'jumlah': jumlah,
      'bukti_pemasukan': bukti_pemasukan,
      'verified_at': verifiedAt?.toIso8601String(),
      'verifier': verifier,
    };
  }

  PemasukanModel copyWith({
    String? id,
    String? nama_pemasukan,
    DateTime? tanggal_pemasukan,
    String? kategori_pemasukan,
    double? jumlah,
    String? bukti_pemasukan,
    DateTime? verifiedAt,
    String? verifier,
  }) {
    return PemasukanModel(
      id: id ?? this.id,
      nama_pemasukan: nama_pemasukan ?? this.nama_pemasukan,
      tanggal_pemasukan: tanggal_pemasukan ?? this.tanggal_pemasukan,
      kategori_pemasukan: kategori_pemasukan ?? this.kategori_pemasukan,
      jumlah: jumlah ?? this.jumlah,
      bukti_pemasukan: bukti_pemasukan ?? this.bukti_pemasukan,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifier: verifier ?? this.verifier,
    );
  }
}
