import 'package:flutter/material.dart';
import 'package:frontend/models/pies.dart';
import 'package:frontend/screens/ekran_filtrow.dart';
import 'package:frontend/screens/ekran_listy.dart';
import 'package:frontend/screens/ekran_ulubionych.dart';

class MenuGlowne extends StatefulWidget {
  const MenuGlowne({super.key});

  @override
  State<MenuGlowne> createState() => _MenuGlowneState();
}

class _MenuGlowneState extends State<MenuGlowne> {
  // stan filtrów
  String filtrPlec = "";
  String filtrKolor = "";
  int filtrWiek = 20;

  // tmp lista ulubionych
  final List<Pies> _ulubionePsy = [];

  // toggle fav pies
  void _przelaczUlubionego(Pies pies) {
    setState(() {
      if (_ulubionePsy.contains(pies)) {
        _ulubionePsy.remove(pies);
      } else {
        _ulubionePsy.add(pies);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tinder dla Psów 🐶"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _budujPrzycisk(
              icon: Icons.tune,
              label: "Ustaw Filtry",
              color: Colors.teal.shade100,
              textColor: Colors.teal.shade900,
              onTap: () async {
                final wynik = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranFiltrow(
                      obecnaPlec: filtrPlec,
                      obecnyKolor: filtrKolor,
                      obecnyWiek: filtrWiek,
                    ),
                  ),
                );
                if (wynik != null) {
                  setState(() {
                    filtrPlec = wynik['plec'];
                    filtrKolor = wynik['kolor'];
                    filtrWiek = wynik['wiek'];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _budujPrzycisk(
              icon: Icons.search,
              label: "Szukaj Psów",
              color: Colors.teal,
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranListy(
                      plec: filtrPlec,
                      kolor: filtrKolor,
                      wiek: filtrWiek,
                      ulubionePsy: _ulubionePsy,
                      onToggleFavorite: _przelaczUlubionego,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // przycisk ulubione
            _budujPrzycisk(
              icon: Icons.favorite,
              label: "Moje Ulubione (${_ulubionePsy.length})",
              color: Colors.pink,
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranUlubionych(
                      ulubionePsy: _ulubionePsy,
                      onToggleFavorite: _przelaczUlubionego,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
            Text(
              "Aktywne filtry:\nPłeć: ${filtrPlec.isEmpty ? 'Każda' : filtrPlec}, "
              "Kolor: ${filtrKolor.isEmpty ? 'Każdy' : filtrKolor}, "
              "Wiek < $filtrWiek",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }

  Widget _budujPrzycisk({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
        ),
        onPressed: onTap,
      ),
    );
  }
}
