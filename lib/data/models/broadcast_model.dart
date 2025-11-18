class BroadcastModel {
  const BroadcastModel({
    required this.id,
    required this.judulBroadcast,
    required this.isiBroadcast,
    this.fotoBroadcast,
    this.dokumenBroadcast,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String judulBroadcast;
  final String isiBroadcast;
  final String? fotoBroadcast;
  final String? dokumenBroadcast;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: json['id'] as String,
      judulBroadcast: (json['judul_broadcast'] ?? '') as String,
      isiBroadcast: (json['isi_broadcast'] ?? '') as String,
      fotoBroadcast: json['foto_broadcast'] as String?,
      dokumenBroadcast: json['dokumen_broadcast'] as String?,
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
      'judul_broadcast': judulBroadcast,
      'isi_broadcast': isiBroadcast,
      'foto_broadcast': fotoBroadcast,
      'dokumen_broadcast': dokumenBroadcast,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toPersistenceMap() {
    return {
      'judul_broadcast': judulBroadcast,
      'isi_broadcast': isiBroadcast,
      'foto_broadcast': fotoBroadcast,
      'dokumen_broadcast': dokumenBroadcast,
    };
  }

  BroadcastModel copyWith({
    String? id,
    String? judulBroadcast,
    String? isiBroadcast,
    String? fotoBroadcast,
    String? dokumenBroadcast,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BroadcastModel(
      id: id ?? this.id,
      judulBroadcast: judulBroadcast ?? this.judulBroadcast,
      isiBroadcast: isiBroadcast ?? this.isiBroadcast,
      fotoBroadcast: fotoBroadcast ?? this.fotoBroadcast,
      dokumenBroadcast: dokumenBroadcast ?? this.dokumenBroadcast,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
