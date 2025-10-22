import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jawara/pages/channel_transfer/channel_transfer_page.dart';
import 'package:jawara/pages/mutasi_keluarga/mutasi_keluarga_page.dart';
import 'package:jawara/pages/pengeluaran/pengeluaran_page.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load Indonesian locale data for intl (DateFormat/NumberFormat)
  await initializeDateFormatting('id_ID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jawara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Jawara Home'),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/pengeluaran': (context) => const PengeluaranPage(),
        '/mutasi-keluarga': (context) => const MutasiKeluargaPage(),
        '/channel-transfer': (context) => const ChannelTransferPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _go(String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Akses Halaman',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _go('/pengeluaran'),
                  icon: const Icon(Icons.payments),
                  label: const Text('Pengeluaran'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _go('/mutasi-keluarga'),
                  icon: const Icon(Icons.group),
                  label: const Text('Mutasi Keluarga'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _go('/channel-transfer'),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Channel Transfer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
