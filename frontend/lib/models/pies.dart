class Pies {
  final int id;
  final String imie;
  final String rasa;
  final int wiek;
  final String plec;
  final String kolor;
  final String opis;
  final String zdjecieUrl;

  Pies({
    required this.id,
    required this.imie,
    required this.rasa,
    required this.wiek,
    required this.plec,
    required this.kolor,
    required this.opis,
    required this.zdjecieUrl,
  });

  factory Pies.fromJson(Map<String, dynamic> json) {
    return Pies(
      id: json['id'],
      imie: json['imie'],
      rasa: json['rasa'],
      wiek: json['wiek'],
      plec: json['plec'],
      kolor: json['kolor'],
      opis: json['opis'] ?? "Brak opisu.",
      zdjecieUrl: json['zdjecie_url'] ?? "https://placedog.net/500/500",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pies && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
