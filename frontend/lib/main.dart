import 'package:flutter/material.dart';
import 'screens/menu_glowne.dart';

void main() {
  runApp(const TinderDlaPsowApp());
}

class TinderDlaPsowApp extends StatelessWidget {
  const TinderDlaPsowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder dla Psów',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MenuGlowne(),
    );
  }
}
