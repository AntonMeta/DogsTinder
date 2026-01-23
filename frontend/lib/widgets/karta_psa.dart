import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/pies.dart';

class KartaPsa extends StatefulWidget {
  final Pies pies;
  final bool czyUlubiony;
  final VoidCallback onFavoritePressed;
  final bool trybUsuwania;

  const KartaPsa({
    super.key,
    required this.pies,
    required this.czyUlubiony,
    required this.onFavoritePressed,
    this.trybUsuwania = false,
  });

  @override
  State<KartaPsa> createState() => _KartaPsaState();
}

class _KartaPsaState extends State<KartaPsa> {
  // Stan do obsługi widoczności opisu
  bool _pokazOpis = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // --- WARSTWA 1: GŁÓWNA TREŚĆ (FOTO/DANE) ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // IMIĘ
                Text(
                  widget.pies.imie,
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),

                // RASA
                Text(
                  widget.pies.rasa.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 30),

                // DETALE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _simpleInfo("WIEK", "${widget.pies.wiek} lata"),
                    _simpleInfo("PŁEĆ", widget.pies.plec),
                    _simpleInfo("KOLOR", widget.pies.kolor),
                  ],
                ),

                const Spacer(),
                const Divider(),

                // PRZYCISK ULUBIONE / USUŃ
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: widget.trybUsuwania
                        ? TextButton.icon(
                            onPressed: widget.onFavoritePressed,
                            icon: const Icon(Icons.close, color: Colors.black),
                            label: const Text("USUŃ",
                                style: TextStyle(color: Colors.black)),
                          )
                        : Icon(
                            widget.czyUlubiony
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.czyUlubiony
                                ? Colors.black
                                : Colors.grey[300],
                            size: 40,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // --- PRZYCISK INFO (IKONA 'i') ---
          // Pojawia się tylko, gdy opis jest ukryty
          AnimatedOpacity(
            opacity: _pokazOpis ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: Colors.black, size: 28),
                  onPressed: () {
                    setState(() {
                      _pokazOpis = true;
                    });
                  },
                ),
              ),
            ),
          ),

          // --- WARSTWA 2: NAKŁADKA Z OPISEM (OVERLAY) ---
          IgnorePointer(
            ignoring: !_pokazOpis, // Klikalne tylko gdy widoczne
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              opacity: _pokazOpis ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.96), // Prawie czarne tło
                padding: const EdgeInsets.all(30.0),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BIO",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "O psie ${widget.pies.imie}",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Biały tekst na czarnym
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "To wspaniały pies, który szuka domu. Jest bardzo energiczny, uwielbia długie spacery i zabawę piłką. Idealny towarzysz dla aktywnych osób.",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[300],
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 40),

                    // PRZYCISK ZAMKNIĘCIA (Biały Outline)
                    Center(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _pokazOpis = false;
                          });
                        },
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text("ZAMKNIJ",
                            style: TextStyle(letterSpacing: 1.0)),
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

  Widget _simpleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
