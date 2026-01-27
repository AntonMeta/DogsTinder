import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/pies.dart';

class KartaPsa extends StatefulWidget {
  final Pies pies;
  final bool czyUlubiony;
  final VoidCallback onFavoritePressed;
  final bool trybUsuwania;
  final bool czySerce;
  final double swipeProgress;

  final bool czyToGornaKarta;

  const KartaPsa({
    super.key,
    required this.pies,
    required this.czyUlubiony,
    required this.onFavoritePressed,
    required this.czySerce,
    this.trybUsuwania = false,
    this.swipeProgress = 0.0,
    this.czyToGornaKarta = false,
  });

  @override
  State<KartaPsa> createState() => _KartaPsaState();
}

class _KartaPsaState extends State<KartaPsa>
    with SingleTickerProviderStateMixin {
  bool _pokazOpis = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _readyToAnimate = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 0.0,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    if (widget.czyToGornaKarta) {
      _uruchomAnimacje();
    }
  }

  @override
  void didUpdateWidget(KartaPsa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.czyToGornaKarta && !oldWidget.czyToGornaKarta) {
      _uruchomAnimacje();
    }
  }

  void _uruchomAnimacje() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _readyToAnimate = true;
          _animController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.swipeProgress.abs().clamp(0.0, 1.0);
    final bool isSwipeRight = widget.swipeProgress > 0;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --- WARSTWA 1: ZDJĘCIE ---
            Image.network(
              widget.pies.zdjecieUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: Colors.grey[200],
                child: const Center(
                    child: Icon(Icons.pets, size: 50, color: Colors.grey)),
              ),
            ),

            // --- WARSTWA 2: GRADIENT FADE ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),

            // --- WARSTWA 3: TREŚĆ KARTY ---
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: Opacity(
                  opacity: _readyToAnimate ? 1.0 : 0.0,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.pies.imie,
                              style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0)),
                          Text(widget.pies.rasa.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  color: Colors.grey[600])),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _simpleInfo("WIEK", "${widget.pies.wiek} lata"),
                              _simpleInfo("PŁEĆ", widget.pies.plec),
                              _simpleInfo("KOLOR", widget.pies.kolor),
                            ],
                          ),
                          if (widget.czySerce) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            Center(
                              child: widget.trybUsuwania
                                  ? TextButton.icon(
                                      onPressed: widget.onFavoritePressed,
                                      icon: const Icon(Icons.close,
                                          color: Colors.black),
                                      label: const Text("USUŃ",
                                          style:
                                              TextStyle(color: Colors.black)))
                                  : IconButton(
                                      onPressed: widget.onFavoritePressed,
                                      icon: Icon(widget.czyUlubiony
                                          ? Icons.favorite
                                          : Icons.favorite_border),
                                      iconSize: 32,
                                      color: Colors.black),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- WARSTWA 4: OVERLAY SWIPE ---
            if (opacity > 0.01)
              Container(
                color: (isSwipeRight ? Colors.red : Colors.grey.shade800)
                    .withOpacity((opacity * 0.6).clamp(0.0, 0.8)),
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 + opacity,
                    child: Icon(
                      isSwipeRight ? Icons.favorite : Icons.close,
                      color: (isSwipeRight ? Colors.red : Colors.grey.shade800)
                          .withOpacity(opacity),
                      size: 100,
                    ),
                  ),
                ),
              ),

            // --- WARSTWA 5: PRZYCISKI I INFO ---
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _pokazOpis ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.black),
                    onPressed: () => setState(() => _pokazOpis = true),
                  ),
                ),
              ),
            ),

            // --- WARSTWA 6: NAKŁADKA BIO ---
            if (_pokazOpis) _buildOverlayBio(),
          ],
        ),
      );
    });
  }

  Widget _buildOverlayBio() {
    return Container(
      color: Colors.black.withOpacity(0.96),
      padding: const EdgeInsets.all(30),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("O PSIE",
                style:
                    GoogleFonts.poppins(color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text(widget.pies.opis,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 16, height: 1.6)),
            const SizedBox(height: 30),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white)),
                onPressed: () => setState(() => _pokazOpis = false),
                child: const Text("ZAMKNIJ"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _simpleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
