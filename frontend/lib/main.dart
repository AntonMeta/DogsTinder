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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MenuGlowne(),
    );
  }
}

// klasa psa

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pies &&
          runtimeType == other.runtimeType &&
          imie == other.imie &&
          rasa == other.rasa &&
          wiek == other.wiek;

  @override
  int get hashCode => imie.hashCode ^ rasa.hashCode ^ wiek.hashCode;
}

// ekran1: menu glowne
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

// ekran2: filtry
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
  List<String> _dostepneKolory = [];
  final TextEditingController _kolorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _plec = widget.obecnaPlec;
    _wiek = widget.obecnyWiek.toDouble();
    _kolorController.text = widget.obecnyKolor;
    pobierzKoloryZSerwera();
  }

  //do autocomplete przy kolorze
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
      debugPrint("Nie udało się pobrać kolorów: $e");
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
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _dostepneKolory.where((String opcja) {
                  return opcja
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                }).take(3);
              },
              onSelected: (String wybor) {
                _kolorController.text = wybor;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                if (controller.text != _kolorController.text) {
                  controller.text = _kolorController.text;
                }
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
                    'kolor': _kolorController.text.trim(),
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

// ekran3: lista wynikow
class EkranListy extends StatefulWidget {
  final String plec;
  final String kolor;
  final int wiek;

  // lista ulubionych i funkcja z menu
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
                      child:
                          Text("Brak psów :(", style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listaPsow.length,
                      itemBuilder: (context, index) {
                        final pies = listaPsow[index];
                        final bool czyUlubiony =
                            widget.ulubionePsy.contains(pies);

                        return KartaPsa(
                          pies: pies,
                          czyUlubiony: czyUlubiony,
                          onFavoritePressed: () {
                            widget.onToggleFavorite(pies);
                            setState(() {});
                          },
                        );
                      },
                    ),
    );
  }
}

// ekran4: ulubione
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
      appBar: AppBar(title: const Text("Moje Ulubione ❤️")),
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
                return KartaPsa(
                  pies: pies,
                  czyUlubiony: true,
                  onFavoritePressed: () {
                    widget.onToggleFavorite(pies);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}

// komponent do wynikow i ulubionych
class KartaPsa extends StatelessWidget {
  final Pies pies;
  final bool czyUlubiony;
  final VoidCallback onFavoritePressed;

  const KartaPsa({
    super.key,
    required this.pies,
    required this.czyUlubiony,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pies.imie,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(pies.plec),
                      backgroundColor: pies.plec == 'Samiec'
                          ? Colors.blue[100]
                          : Colors.pink[100],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        czyUlubiony ? Icons.favorite : Icons.favorite_border,
                        color: czyUlubiony ? Colors.pink : Colors.grey,
                        size: 30,
                      ),
                      onPressed: onFavoritePressed,
                    )
                  ],
                )
              ],
            ),
            const Divider(),
            Text("Rasa: ${pies.rasa}", style: const TextStyle(fontSize: 16)),
            Text("Wiek: ${pies.wiek} lat(a)",
                style: const TextStyle(fontSize: 16)),
            Text("Kolor: ${pies.kolor}", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
