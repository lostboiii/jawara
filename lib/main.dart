import 'package:flutter/material.dart';
import 'route/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Jawara Pintar',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
    );
  }
}