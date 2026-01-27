import 'package:flutter/material.dart';
import 'package:frontend/models/pies.dart';
import 'package:frontend/screens/ekran_filtrow.dart';
import 'package:frontend/screens/ekran_listy.dart';
import 'package:frontend/screens/ekran_ulubionych.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuGlowne extends StatefulWidget {
  const MenuGlowne({super.key});

  @override
  State<MenuGlowne> createState() => _MenuGlowneState();
}

class _MenuGlowneState extends State<MenuGlowne>
    with SingleTickerProviderStateMixin {
  // filters
  String filtrPlec = "";
  String filtrKolor = "";
  int filtrWiek = 20;

  // lists
  final List<Pies> _ulubionePsy = [];
  final Set<int> _odwiedzonePsyIds = {};

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // toggle fav pies
  void _przelaczUlubionego(Pies pies) {
    setState(() {
      if (_ulubionePsy.contains(pies)) {
        _ulubionePsy.remove(pies);
        _odwiedzonePsyIds.remove(pies.id);
      } else {
        _ulubionePsy.add(pies);
        _odwiedzonePsyIds.add(pies.id);
      }
    });
  }

  // seen
  void _oznaczJakoOdwiedzony(int id) {
    setState(() {
      _odwiedzonePsyIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              _budujAnimowanyElement(
                start: 0.0,
                end: 0.5,
                child: Text(
                  "Dogs",
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              _budujAnimowanyElement(
                start: 0.1,
                end: 0.5,
                child: Text(
                  "Tinder.",
                  style: GoogleFonts.poppins(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _budujAnimowanyElement(
                start: 0.2,
                end: 0.6,
                child: Text(
                  "Znajdź swojego przyjaciela.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const Spacer(),

              // buttons
              _budujAnimowanyElement(
                start: 0.4,
                end: 0.8,
                child: _budujPrzycisk(
                  label: "SZUKAJ PARY",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EkranListy(
                          plec: filtrPlec,
                          kolor: filtrKolor,
                          wiek: filtrWiek,
                          ulubionePsy: _ulubionePsy,
                          odwiedzonePsyIds: _odwiedzonePsyIds,
                          onToggleFavorite: _przelaczUlubionego,
                          onOdwiedzony: _oznaczJakoOdwiedzony,
                        ),
                      ),
                    );
                  },
                  isPrimary: true,
                ),
              ),
              const SizedBox(height: 15),
              _budujAnimowanyElement(
                start: 0.5,
                end: 0.9,
                child: _budujPrzycisk(
                  label: "FILTRY",
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
                        _odwiedzonePsyIds.clear();
                      });
                    }
                  },
                  isPrimary: false,
                ),
              ),
              const SizedBox(height: 15),
              _budujAnimowanyElement(
                start: 0.6,
                end: 1.0,
                child: _budujPrzycisk(
                  label: "MOJE ULUBIONE (${_ulubionePsy.length})",
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
                  isPrimary: false,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _budujAnimowanyElement({
    required double start,
    required double end,
    required Widget child,
  }) {
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: child,
      ),
    );
  }

  Widget _budujPrzycisk({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onTap,
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.black,
              ),
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, letterSpacing: 1.0),
              ),
            ),
    );
  }
}
