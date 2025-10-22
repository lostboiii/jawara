class ChannelItem {
  String nama;
  String tipe; // bank | ewallet | qris
  String nomor; // nomor rekening/akun
  String an; // atas nama
  String? qrPath; // path lokal file QR (opsional)
  String? thumbnailPath; // path lokal thumbnail (opsional)
  String? catatan; // opsional

  ChannelItem({
    required this.nama,
    required this.tipe,
    required this.nomor,
    required this.an,
    this.qrPath,
    this.thumbnailPath,
    this.catatan,
  });
}
