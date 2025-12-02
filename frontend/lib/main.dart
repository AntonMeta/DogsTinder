import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TinderDlaPsowApp());
}

class TinderDlaPsowApp extends StatelessWidget {
  const TinderDlaPsowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder dla Psów',
      theme: ThemeData(
        // Zmieniamy kolor wiodący na zielony - bardziej pasuje do "schroniska/nadziei"
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MenuGlowne(),
    );
  }
}

// --- MODEL DANYCH ---
class Pies {
  final String imie;
  final String rasa;
  final int wiek;
  final String plec;
  final String kolor;

  Pies({
    required this.imie,
    required this.rasa,
    required this.wiek,
    required this.plec,
    required this.kolor,
  });

  factory Pies.fromJson(Map<String, dynamic> json) {
    return Pies(
      imie: json['imie'],
      rasa: json['rasa'],
      wiek: json['wiek'],
      plec: json['plec'],
      kolor: json['kolor'],
    );
  }
}

// --- EKRAN 1: MENU GŁÓWNE (HUB) ---
class MenuGlowne extends StatefulWidget {
  const MenuGlowne({super.key});

  @override
  State<MenuGlowne> createState() => _MenuGlowneState();
}

class _MenuGlowneState extends State<MenuGlowne> {
  // Tutaj trzymamy stan filtrów dla całej aplikacji
  String filtrPlec = ""; // Puste oznacza "Wszystkie"
  String filtrKolor = "";
  int filtrWiek = 20; // Domyślnie szukamy psów do 20 lat (czyli wszystkich)

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
            // Przycisk 1: FILTRY
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.tune, size: 28),
                label:
                    const Text("Ustaw Filtry", style: TextStyle(fontSize: 18)),
                onPressed: () async {
                  // Czekamy na powrót z ekranu filtrów z nowymi ustawieniami
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

                  // Jeśli użytkownik zapisał filtry, aktualizujemy stan Menu
                  if (wynik != null) {
                    setState(() {
                      filtrPlec = wynik['plec'];
                      filtrKolor = wynik['kolor'];
                      filtrWiek = wynik['wiek'];
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 30),

            // Przycisk 2: WYNIKI
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search, size: 28),
                label:
                    const Text("Szukaj Psów", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Przechodzimy do listy, przekazując aktualne filtry
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EkranListy(
                        plec: filtrPlec,
                        kolor: filtrKolor,
                        wiek: filtrWiek,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Podgląd aktualnych filtrów (dla wygody)
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
}

// --- EKRAN 2: KONFIGURACJA FILTRÓW (Z AUTOCOMPLETE) ---
class EkranFiltrow extends StatefulWidget {
  final String obecnaPlec;
  final String obecnyKolor;
  final int obecnyWiek;

  const EkranFiltrow({
    super.key,
    required this.obecnaPlec,
    required this.obecnyKolor,
    required this.obecnyWiek,
  });

  @override
  State<EkranFiltrow> createState() => _EkranFiltrowState();
}

class _EkranFiltrowState extends State<EkranFiltrow> {
  late String _plec;
  late double _wiek;

  // To będzie nasza lista podpowiedzi pobrana z serwera
  List<String> _dostepneKolory = [];

  // Kontroler potrzebny, by wyciągnąć tekst, nawet jak użytkownik nie kliknie w podpowiedź
  final TextEditingController _kolorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plec = widget.obecnaPlec;
    _wiek = widget.obecnyWiek.toDouble();
    _kolorController.text = widget.obecnyKolor;

    // Od razu po wejściu na ekran pobieramy listę kolorów
    pobierzKoloryZSerwera();
  }

  Future<void> pobierzKoloryZSerwera() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/kolory');
      final odpowiedz = await http.get(url);
      if (odpowiedz.statusCode == 200) {
        final List<dynamic> dane = jsonDecode(utf8.decode(odpowiedz.bodyBytes));
        setState(() {
          _dostepneKolory = dane.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      print("Nie udało się pobrać kolorów: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferencje")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Płeć psa:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _plec.isEmpty ? null : _plec,
              hint: const Text("Obie płcie"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "", child: Text("Wszystkie")),
                DropdownMenuItem(value: "Samiec", child: Text("Samiec")),
                DropdownMenuItem(value: "Samica", child: Text("Samica")),
              ],
              onChanged: (val) {
                setState(() => _plec = val ?? "");
              },
            ),
            const SizedBox(height: 20),

            const Text("Kolor sierści:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            // --- TU JEST MAGIA: AUTOCOMPLETE ---
            Autocomplete<String>(
              // 1. Podpinamy nasze opcje pobrane z Pythona
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                // Filtrujemy: szukamy tekstu wpisanego przez usera w naszej liście
                // .take(3) oznacza: "pokaż maksymalnie 3 wyniki"
                return _dostepneKolory.where((String opcja) {
                  return opcja
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                }).take(3);
              },

              // 2. Co się dzieje jak klikniesz w podpowiedź
              onSelected: (String wybor) {
                _kolorController.text = wybor;
              },

              // 3. Budowa pola tekstowego (wygląd)
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                // Musimy zsynchronizować nasz kontroler z kontrolerem Autocomplete
                // Hack: jeśli nasz kontroler ma tekst (np. przy edycji), przepisujemy go
                if (controller.text != _kolorController.text) {
                  controller.text = _kolorController.text;
                }

                // Nasłuchujemy zmian, żeby aktualizować nasz główny kontroler
                controller.addListener(() {
                  _kolorController.text = controller.text;
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    hintText: "Zacznij pisać, np. Cza...",
                    suffixIcon: Icon(Icons.palette),
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Text("Maksymalny wiek: ${_wiek.toInt()} lat",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _wiek,
              min: 1,
              max: 20,
              divisions: 19,
              label: _wiek.toInt().toString(),
              onChanged: (val) => setState(() => _wiek = val),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'plec': _plec,
                    'kolor': _kolorController.text
                        .trim(), // Pobieramy tekst z kontrolera
                    'wiek': _wiek.toInt(),
                  });
                },
                child: const Text("ZAPISZ FILTRY"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- EKRAN 3: LISTA WYNIKÓW ---
class EkranListy extends StatefulWidget {
  final String plec;
  final String kolor;
  final int wiek;

  const EkranListy({
    super.key,
    required this.plec,
    required this.kolor,
    required this.wiek,
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
      // Budujemy URL z parametrami z filtrów
      // Uwaga: używamy endpointu /szukaj, a nie /psy
      final queryParams = {
        'wiek': widget.wiek.toString(),
        'plec': widget.plec,
        'kolor': widget.kolor,
      };

      // Budowa pełnego adresu URI
      final uri = Uri.http('127.0.0.1:8000', '/szukaj', queryParams);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dopasowane psy")),
      body: ladowanie
          ? const Center(child: CircularProgressIndicator())
          : blad.isNotEmpty
              ? Center(
                  child: Text(blad, style: const TextStyle(color: Colors.red)))
              : listaPsow.isEmpty
                  ? const Center(
                      child: Text("Brak psów spełniających kryteria :(",
                          style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listaPsow.length,
                      itemBuilder: (context, index) {
                        final pies = listaPsow[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pies.imie,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Chip(
                                      label: Text(pies.plec),
                                      backgroundColor: pies.plec == 'Samiec'
                                          ? Colors.blue[100]
                                          : Colors.pink[100],
                                    )
                                  ],
                                ),
                                const Divider(),
                                Text("Rasa: ${pies.rasa}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Wiek: ${pies.wiek} lat(a)",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Kolor: ${pies.kolor}",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
