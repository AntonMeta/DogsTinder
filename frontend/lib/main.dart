import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import czcionek
import 'screens/menu_glowne.dart';

void main() {
  runApp(const TinderDlaPsowApp());
}

class TinderDlaPsowApp extends StatelessWidget {
  const TinderDlaPsowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DogsTinder', // Bez "dla Psów" i emotek
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // TŁO: Czysta biel
        scaffoldBackgroundColor: Colors.white,

        // KOLORYSTYKA: Czerń i Biel
        colorScheme: const ColorScheme.light(
          primary: Colors.black, // Główny kolor to czarny
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          outline: Colors.black12, // Delikatne linie
        ),

        // TYPOGRAFIA: Nowoczesna, geometryczna (Poppins lub Lato)
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),

        // PRZYCISKI: Kwadratowe, czarne, minimalistyczne
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Czarne tło
            foregroundColor: Colors.white, // Biały tekst
            elevation: 0, // PŁASKIE (brak cienia)
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Lekkie zaokrąglenie
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 1.0, // Rozstrzelony tekst (wygląda premium)
            ),
          ),
        ),

        // APP BAR: Biały, czysty, bez cienia
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      home: const MenuGlowne(),
    );
  }
}
