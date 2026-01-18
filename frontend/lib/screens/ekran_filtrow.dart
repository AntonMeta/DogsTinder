import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
