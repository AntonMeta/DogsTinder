import 'package:flutter/material.dart';
import 'package:frontend/models/pies.dart';
import 'package:frontend/widgets/karta_psa.dart';

class EkranUlubionych extends StatefulWidget {
  final List<Pies> ulubionePsy;
  final Function(Pies) onToggleFavorite;

  const EkranUlubionych({
    super.key,
    required this.ulubionePsy,
    required this.onToggleFavorite,
  });

  @override
  State<EkranUlubionych> createState() => _EkranUlubionychState();
}

class _EkranUlubionychState extends State<EkranUlubionych> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moje Ulubione")),
      body: widget.ulubionePsy.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Nie masz jeszcze ulubionych psów.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.ulubionePsy.length,
              itemBuilder: (context, index) {
                final pies = widget.ulubionePsy[index];
                return SizedBox(
                  height:
                      500, // Wymuszamy wysokość, żeby karta wyglądała tak samo jak w swipowaniu
                  child: KartaPsa(
                    pies: pies,
                    czyUlubiony: true, // Tu zawsze jest true
                    trybUsuwania: true,
                    czySerce: true, // <--- WAŻNE: Włączamy przycisk usuwania!
                    onFavoritePressed: () {
                      widget.onToggleFavorite(pies);
                      setState(() {}); // Odświeżamy, żeby usunięty pies zniknął
                    },
                  ),
                );
              },
            ),
    );
  }
}
