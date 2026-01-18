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
