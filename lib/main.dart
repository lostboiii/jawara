import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';
import 'package:jawara/data/repositories/metode_pembayaran_repository.dart';
import 'package:jawara/viewmodels/metode_pembayaran_viewmodel.dart';
import 'package:jawara/data/repositories/broadcast_repository.dart';
import 'package:jawara/viewmodels/broadcast_viewmodel.dart';
import 'package:jawara/data/repositories/kegiatan_repository.dart';
import 'package:jawara/viewmodels/kegiatan_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with hardcoded credentials
  // (These should come from .env in production, but we initialize directly here for now)
  try {
    await Supabase.initialize(
      url: 'https://fbyriwzdgdihwqxvbzmy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZieXJpd3pkZ2RpaHdxeHZiem15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NDk2MTgsImV4cCI6MjA3ODMyNTYxOH0.ZcTM8gFTsCfKMm1qDlo5aHRphtuH6Y9UhFWBHu2nuvA',
    );
    debugPrint('✓ Supabase initialized');
  } catch (e) {
    debugPrint('✗ Supabase init error: $e');
  }

  // Load Indonesian locale data
  await initializeDateFormatting('id_ID');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => SupabaseAuthService(client: supabaseClient),
        ),
        Provider<WargaRepository>(
          create: (_) => SupabaseWargaRepository(client: supabaseClient),
        ),
        Provider<PengeluaranRepository>(
          create: (_) => SupabasePengeluaranRepository(client: supabaseClient),
        ),
        Provider<MetodePembayaranRepository>(
          create: (_) =>
              SupabaseMetodePembayaranRepository(client: supabaseClient),
        ),
        Provider<BroadcastRepository>(
          create: (_) => SupabaseBroadcastRepository(client: supabaseClient),
        ),
        Provider<KegiatanRepository>(
          create: (_) => SupabaseKegiatanRepository(client: supabaseClient),
        ),
        ChangeNotifierProvider(
          create: (context) => RegisterViewModel(
            authService: context.read<AuthService>(),
            wargaRepository: context.read<WargaRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PengeluaranViewModel(
            repository: context.read<PengeluaranRepository>(),
          )..loadPengeluaran(),
        ),
        ChangeNotifierProvider(
          create: (context) => MetodePembayaranViewModel(
            repository: context.read<MetodePembayaranRepository>(),
          )..loadMetodePembayaran(),
        ),
        ChangeNotifierProvider(
          create: (context) => BroadcastViewModel(
            repository: context.read<BroadcastRepository>(),
          )..loadBroadcasts(),
        ),
        ChangeNotifierProvider(
          create: (context) => KegiatanViewModel(
            repository: context.read<KegiatanRepository>(),
          )..loadKegiatan(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              // Tampilkan dialog konfirmasi keluar aplikasi
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar Aplikasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              return shouldPop ?? false;
            },
            child: MaterialApp.router(
              title: 'Jawara',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              routerConfig: appRouter,
              locale: const Locale('id', 'ID'),
              supportedLocales: const [Locale('id', 'ID'), Locale('en', '')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
        },
      ),
    );
  }
}
