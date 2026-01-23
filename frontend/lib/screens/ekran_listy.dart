import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:frontend/models/pies.dart';
import 'package:frontend/widgets/karta_psa.dart';
import 'package:http/http.dart' as http;

class EkranListy extends StatefulWidget {
  final String plec;
  final String kolor;
  final int wiek;
  final List<Pies> ulubionePsy;
  final Function(Pies) onToggleFavorite;

  const EkranListy({
    super.key,
    required this.plec,
    required this.kolor,
    required this.wiek,
    required this.ulubionePsy,
    required this.onToggleFavorite,
  });

  @override
  State<EkranListy> createState() => _EkranListyState();
}

class _EkranListyState extends State<EkranListy> {
  List<Pies> listaPsow = [];
  bool ladowanie = true;
  String blad = '';

  @override
  void initState() {
    super.initState();
    szukajPsow();
  }

  Future<void> szukajPsow() async {
    try {
      final queryParams = {
        'wiek': widget.wiek.toString(),
        'plec': widget.plec,
        'kolor': widget.kolor,
      };
      final uri = Uri.http('0.0.0.0:8000', '/szukaj', queryParams);
      final odpowiedz = await http.get(uri);

      if (odpowiedz.statusCode == 200) {
        final List<dynamic> daneJson =
            jsonDecode(utf8.decode(odpowiedz.bodyBytes));
        setState(() {
          listaPsow = daneJson.map((json) => Pies.fromJson(json)).toList();
          ladowanie = false;
        });
      } else {
        throw Exception('Błąd serwera: ${odpowiedz.statusCode}');
      }
    } catch (e) {
      setState(() {
        blad = 'Błąd połączenia: $e';
        ladowanie = false;
      });
    }
  }

  // Funkcja obsługująca przesunięcie karty
  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final pies = listaPsow[previousIndex];

    // Logika: Prawo = Ulubione, Lewo = Pomiń
    if (direction == CardSwiperDirection.right) {
      // Jeśli psa nie ma jeszcze w ulubionych, dodajemy go
      if (!widget.ulubionePsy.contains(pies)) {
        widget.onToggleFavorite(pies);

        // Opcjonalnie: Pokazujemy mały komunikat na dole ekranu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dodano do ulubionych: ${pies.imie}! ❤️"),
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.pink,
          ),
        );
      }
    } else if (direction == CardSwiperDirection.left) {
      // W lewo nic nie robimy (po prostu pomijamy)
      // Ewentualnie można tu dodać logikę usuwania, jeśli chcemy
    }

    return true; // Zwracamy true, żeby pozwolić na przesunięcie
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szukaj pary")),
      body: ladowanie
          ? const Center(child: CircularProgressIndicator())
          : blad.isNotEmpty
              ? Center(
                  child: Text(blad, style: const TextStyle(color: Colors.red)))
              : listaPsow.isEmpty
                  ? const Center(
                      child: Text("Brak psów spełniających kryteria :(",
                          style: TextStyle(fontSize: 18)))
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Znaleziono: ${listaPsow.length} psiaków",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Stack(
                              children: [
                                // --- WARSTWA SPODNIA ---
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          size: 80, color: Colors.grey),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "To już wszystkie pieski!",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("WRÓĆ DO MENU"),
                                      )
                                    ],
                                  ),
                                ),

                                // --- WARSTWA WIERZCHNIA ---
                                CardSwiper(
                                  cardsCount: listaPsow.length,
                                  isLoop: false,
                                  onSwipe: _onSwipe,
                                  numberOfCardsDisplayed: listaPsow.length < 3
                                      ? listaPsow.length
                                      : 3,
                                  backCardOffset: const Offset(0, 40),
                                  padding: const EdgeInsets.only(bottom: 40),

                                  // --- POPRAWIONY BUILDER ---
                                  cardBuilder: (context, index,
                                      percentThresholdX, percentThresholdY) {
                                    final pies = listaPsow[index];

                                    Widget baseCard = SizedBox(
                                      width: double.infinity,
                                      height: 500,
                                      child: KartaPsa(
                                        pies: pies,
                                        czyUlubiony:
                                            widget.ulubionePsy.contains(pies),
                                        onFavoritePressed: () {},
                                      ),
                                    );

                                    // POPRAWKA 1: Dodane .toDouble()
                                    double dragDistance =
                                        percentThresholdX.toDouble();

                                    // Obliczamy opacity (przezroczystość)
                                    double opacity = (dragDistance.abs() / 150)
                                        .clamp(0.0, 0.5);

                                    Color tintColor = Colors.transparent;
                                    IconData? tintIcon;

                                    if (dragDistance > 0) {
                                      tintColor = Colors.green;
                                      tintIcon = Icons.check_circle;
                                    } else if (dragDistance < 0) {
                                      tintColor = Colors.red;
                                      tintIcon = Icons.cancel;
                                    }

                                    return Stack(
                                      children: [
                                        baseCard,
                                        if (opacity > 0)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: tintColor
                                                    .withOpacity(opacity),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  tintIcon,
                                                  // POPRAWKA 2: clamp przeniesiony do środka
                                                  color: Colors.white
                                                      .withOpacity(
                                                          (opacity * 1.8)
                                                              .clamp(0.0, 1.0)),
                                                  size: 100,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "👈 Pomiń   |   Polub 👉",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }
}
