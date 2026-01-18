import 'package:flutter/material.dart';
import 'package:frontend/models/pies.dart';

class KartaPsa extends StatefulWidget {
  final Pies pies;
  final bool czyUlubiony;
  final VoidCallback onFavoritePressed;
  final bool trybUsuwania; // Nowe pole

  const KartaPsa({
    super.key,
    required this.pies,
    required this.czyUlubiony,
    required this.onFavoritePressed,
    this.trybUsuwania = false, // Domyślnie false (dla Swipowania)
  });

  @override
  State<KartaPsa> createState() => _KartaPsaState();
}

class _KartaPsaState extends State<KartaPsa> {
  bool _pokazOpis = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // --- WARSTWA 1: TREŚĆ GŁÓWNA ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.pies.imie,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(widget.pies.plec),
                      backgroundColor: widget.pies.plec == 'Samiec'
                          ? Colors.blue[100]
                          : Colors.pink[100],
                    ),
                  ],
                ),
                const Divider(height: 30),
                _wierszInfo(Icons.pets, "Rasa", widget.pies.rasa, Colors.black),
                const SizedBox(height: 10),
                _wierszInfo(Icons.cake, "Wiek", "${widget.pies.wiek} lat(a)",
                    Colors.black),
                const SizedBox(height: 10),
                _wierszInfo(
                    Icons.palette, "Kolor", widget.pies.kolor, Colors.black),

                const SizedBox(height: 30),

                // --- LOGIKA PRZYCISKU VS IKONY ---
                Center(
                  child: widget.trybUsuwania
                      ?
                      // 1. WIDOK W ZAKŁADCE ULUBIONE (Przycisk usuwania)
                      ElevatedButton.icon(
                          onPressed: widget.onFavoritePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("USUŃ Z ULUBIONYCH"),
                        )
                      :
                      // 2. WIDOK W SWIPOWANIU (Statyczna ikona statusu)
                      Column(
                          children: [
                            Icon(
                              widget.czyUlubiony
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.czyUlubiony
                                  ? Colors.pink
                                  : Colors.grey[300],
                              size: 50,
                            ),
                            if (widget.czyUlubiony)
                              const Text("To Twój ulubieniec!",
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 12))
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Przycisk "I" (zamykany animacją)
          AnimatedOpacity(
            opacity: _pokazOpis ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: const Icon(Icons.info_outline,
                      size: 30, color: Colors.blue),
                  onPressed: _pokazOpis
                      ? null
                      : () {
                          setState(() {
                            _pokazOpis = true;
                          });
                        },
                ),
              ),
            ),
          ),

          // --- WARSTWA 2: OPIS (BIO) ---
          IgnorePointer(
            ignoring: !_pokazOpis,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: _pokazOpis ? 1.0 : 0.0,
              child: Container(
                color: primaryColor.withOpacity(0.96),
                padding: const EdgeInsets.all(24.0),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "O psie ${widget.pies.imie}:",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                      "Pies jest bardzo energiczny, uwielbia długie spacery i zabawę piłką. "
                      "Szuka domu z ogrodem, ale odnajdzie się też w mieszkaniu.",
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.white),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _pokazOpis = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Zamknij opis"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wierszInfo(
      IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text("$label: ",
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
      ],
    );
  }
}
