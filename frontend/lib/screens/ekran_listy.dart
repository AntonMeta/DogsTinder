import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/pies.dart';
import 'package:frontend/widgets/karta_psa.dart';

class EkranListy extends StatefulWidget {
  final String plec;
  final String kolor;
  final int wiek;
  final List<Pies> ulubionePsy;
  final Set<int> odwiedzonePsyIds;
  final Function(Pies) onToggleFavorite;
  final Function(int) onOdwiedzony;

  const EkranListy({
    super.key,
    required this.plec,
    required this.kolor,
    required this.wiek,
    required this.ulubionePsy,
    required this.odwiedzonePsyIds,
    required this.onToggleFavorite,
    required this.onOdwiedzony,
  });

  @override
  State<EkranListy> createState() => _EkranListyState();
}

class _EkranListyState extends State<EkranListy>
    with SingleTickerProviderStateMixin {
  List<Pies> listaPsow = [];
  bool ladowanie = true;
  String blad = '';
  bool _czyKoniec = false;

  int _currentIndex = 0;

  Key _swiperKey = UniqueKey();
  final CardSwiperController _swiperController = CardSwiperController();

  late AnimationController _loaderController;
  late Animation<double> _loaderAnimation;

  @override
  void initState() {
    super.initState();

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _loaderAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );
    szukajPsow();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  Future<void> szukajPsow({bool czyscHistorie = false}) async {
    if (czyscHistorie) {
      widget.odwiedzonePsyIds.clear();
    }

    setState(() {
      ladowanie = true;
      _czyKoniec = false;
      blad = '';
      _currentIndex = 0;
    });
    try {
      final queryParams = {
        'wiek': widget.wiek.toString(),
        'plec': widget.plec,
        'kolor': widget.kolor,
      };
      final uri = Uri.http('localhost:8000', '/szukaj', queryParams);

      final results = await Future.wait([
        http.get(uri),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);

      final odpowiedz = results[0] as http.Response;

      if (odpowiedz.statusCode == 200) {
        final bodyDecoded = utf8.decode(odpowiedz.bodyBytes);
        final List<dynamic> daneJson = json.decode(bodyDecoded);

        final wszystkiePsy =
            daneJson.map((json) => Pies.fromJson(json)).toList();

        final przefiltrowane = wszystkiePsy.where((pies) {
          final bool czyOdwiedzony = widget.odwiedzonePsyIds.contains(pies.id);
          final bool czyUlubiony =
              widget.ulubionePsy.any((p) => p.id == pies.id);

          return !czyOdwiedzony && !czyUlubiony;
        }).toList();

        setState(() {
          listaPsow = przefiltrowane;
          ladowanie = false;
          _swiperKey = UniqueKey();
        });
      } else {
        setState(() {
          blad = 'Błąd serwera: ${odpowiedz.statusCode}';
          ladowanie = false;
        });
      }
    } catch (e) {
      setState(() {
        blad = 'Błąd połączenia: $e';
        ladowanie = false;
      });
    }
  }

  bool _obslugaSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final pies = listaPsow[previousIndex];

    widget.onOdwiedzony(pies.id);

    if (currentIndex != null) {
      setState(() {
        _currentIndex = currentIndex;
      });
    }

    if (direction == CardSwiperDirection.right) {
      if (!widget.ulubionePsy.contains(pies)) {
        widget.onToggleFavorite(pies);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Polubiono: ${pies.imie}"),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
          ),
        );
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szukaj pary"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ladowanie
          ? _budujLoader()
          : blad.isNotEmpty
              ? Center(
                  child: Text(blad, style: const TextStyle(color: Colors.red)))
              : _czyKoniec
                  ? _budujEkranKoncowy()
                  : listaPsow.isEmpty
                      ? const Center(
                          child: Text("Brak psów spełniających kryteria"))
                      : SafeArea(
                          child: Column(
                            children: [
                              Flexible(
                                child: CardSwiper(
                                  key: _swiperKey,
                                  controller: _swiperController,
                                  cardsCount: listaPsow.length,
                                  numberOfCardsDisplayed:
                                      listaPsow.length > 1 ? 2 : 1,
                                  isLoop: false,
                                  onEnd: () {
                                    setState(() {
                                      _czyKoniec = true;
                                    });
                                  },
                                  backCardOffset: const Offset(0, 40),
                                  padding: const EdgeInsets.all(24.0),
                                  onSwipe: _obslugaSwipe,
                                  cardBuilder: (context, index,
                                      percentThresholdX, percentThresholdY) {
                                    if (index >= listaPsow.length) {
                                      return const SizedBox();
                                    }
                                    final pies = listaPsow[index];
                                    return KartaPsa(
                                      key: ValueKey(pies.id),
                                      pies: pies,
                                      czyUlubiony:
                                          widget.ulubionePsy.contains(pies),
                                      czySerce: false,
                                      onFavoritePressed: () =>
                                          widget.onToggleFavorite(pies),
                                      swipeProgress:
                                          percentThresholdX as double,
                                      czyToGornaKarta: index == _currentIndex,
                                    );
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  "👈 Pomiń   |   Polub 👉",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
    );
  }

  Widget _budujLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _loaderAnimation,
            child: const Icon(
              Icons.pets,
              size: 60,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Szukam piesków...",
            style: TextStyle(
                color: Colors.grey[400],
                letterSpacing: 1.5,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _budujEkranKoncowy() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "To już wszystkie psy!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Zmień filtry lub odśwież listę.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              szukajPsow(czyscHistorie: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text("ODŚWIEŻ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          )
        ],
      ),
    );
  }
}
