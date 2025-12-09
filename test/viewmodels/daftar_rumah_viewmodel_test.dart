import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/daftar_rumah_viewmodel.dart';

void main() {
  group('DaftarRumahViewModel Tests', () {
    // TODO: Implement test untuk loadRumahs()
    // Fitur: Load semua rumah dengan agregasi count warga per rumah
    // Query: SELECT *, rumahs_wargas(count) FROM rumahs ORDER BY no_rumah
    // Digunakan di: lib/ui/pages/rumah/daftar_rumah_page.dart
    test('loadRumahs should fetch rumahs with warga count', () {
      // TODO: Mock Supabase client
      // TODO: Test successful fetch with order by no_rumah
      // TODO: Test empty result
      // TODO: Test error handling and rethrow
      // TODO: Test loading state changes
    });

    // TODO: Implement test untuk initial state
    test('initial state should be correct', () {
      // TODO: Test rumahs = []
      // TODO: Test isLoading = false
      // TODO: Test errorMessage = null
    });
  });
}
