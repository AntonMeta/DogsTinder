import os
import sys

# klasa psa
class Pies:
    def __init__(self, imie, rasa, wiek, plec, kolor):
        self.imie = imie
        self.rasa = rasa
        self.wiek = int(wiek)
        self.plec = plec
        self.kolor = kolor

    def __str__(self):
        # formatowanie do printa
        return f"| {self.imie:^12} | {self.rasa:^15} | {self.wiek:^4} lat | {self.plec:^6} | {self.kolor:^12} |"

def wczytaj_psy(nazwa_pliku):
    # wczytuje psy z pliku i zwraca ich liste
    lista_psow = []
    
    if not os.path.exists(nazwa_pliku):
        print("\n" + "!"*50)
        print(f"[BŁĄD KRYTYCZNY] Nie znaleziono pliku: {nazwa_pliku}")
        print("Program nie może działać bez bazy danych.")
        print("Upewnij się, że plik istnieje i uruchom program ponownie.")
        print("\n" + "!"*50)
        sys.exit()

    try:
        with open(nazwa_pliku, 'r', encoding='utf-8') as f:
            for linia in f:
                linia = linia.strip()
                if linia:
                    dane = linia.split(',')
                    if len(dane) == 5:
                        pies = Pies(dane[0], dane[1], dane[2], dane[3], dane[4])
                        lista_psow.append(pies)
    except ValueError:
        print("[BLAD] Plik zawiera błędne dane.")
    
    return lista_psow

# narzedzia interfejsu terminalowego
def wyczysc_ekran():
    os.system('clear')

def pauza():
    input("\n[Naciśnij ENTER, aby wrócić do menu...]")

def wyswietl_naglowek_tabeli():
    print("="*70)
    print(f"| {'IMIE':^12} | {'RASA':^15} | {'WIEK':^8} | {'PLEC':^6} | {'KOLOR':^12} |")
    print("="*70)

def pobierz_unikalne_opcje(lista_psow, atrybut):
    opcje = {str(getattr(pies, atrybut)) for pies in lista_psow}
    return sorted(list(opcje))

# glowna funkcja programu
def szukaj_psa(lista_psow):
    print("--- FILTRY WYSZUKIWANIA ---")
    print("(Wciśnij ENTER, aby pominąć wybrane kryterium)\n")
    
    # plec
    dostepne_plcie = pobierz_unikalne_opcje(lista_psow, 'plec')
    print(f"-> Dostępne płcie: {', '.join(dostepne_plcie)}")
    pref_plec = input("   Wybierz płeć: ").strip().capitalize()

    # kolor
    dostepne_kolory = pobierz_unikalne_opcje(lista_psow, 'kolor')
    print(f"\n-> Dostępne kolory: {', '.join(dostepne_kolory)}")
    pref_kolor = input("   Wybierz kolor: ").strip().capitalize()

    # wiek
    dostepne_wieki = [pies.wiek for pies in lista_psow]
    if dostepne_wieki:
        print(f"\n-> Zakres wieku psów: {min(dostepne_wieki)} - {max(dostepne_wieki)} lat")
    
    pref_wiek_str = input("   Maksymalny wiek psa: ").strip()

    pref_wiek = -1
    if pref_wiek_str:
        try:
            pref_wiek = int(pref_wiek_str)
        except ValueError:
            print("   [INFO] Błędny format wieku, filtr pominięty.")

    # filtr
    znalezione = []
    for pies in lista_psow:
        zgodnosc_plec = (pref_plec == "" or pies.plec == pref_plec)
        zgodnosc_kolor = (pref_kolor == "" or pies.kolor == pref_kolor)
        zgodnosc_wiek = (pref_wiek == -1 or pies.wiek <= pref_wiek)

        if zgodnosc_plec and zgodnosc_kolor and zgodnosc_wiek:
            znalezione.append(pies)

    # print wyników
    wyczysc_ekran()
    if znalezione:
        print(f"\n[SUKCES] Znaleziono pasujące psy: {len(znalezione)}\n")
        wyswietl_naglowek_tabeli()
        for pies in znalezione:
            print(pies)
        print("="*70)
    else:
        print("\n[SMUTEK] Niestety, żaden pies nie spełnia Twoich wymagań.")
    
    pauza()

def pokaz_wszystkie(lista_psow):
    print(f"\n[BAZA] Lista wszystkich psów w schronisku: {len(lista_psow)}\n")
    wyswietl_naglowek_tabeli()
    for p in lista_psow:
        print(p)
    print("="*70)
    pauza()

def main():
    plik_danych = "psy.csv"
    baza_psow = wczytaj_psy(plik_danych)

    while True:
        wyczysc_ekran()
        print("########################################")
        print("#           TINDER DLA PSÓW            #")
        print("########################################")
        print("# 1. Szukaj przyjaciela (Filtrowanie)  #")
        print("# 2. Zobacz całą gromadkę              #")
        print("# 3. Wyjdź                             #")
        print("########################################")
        
        wybor = input("\nTwój wybór > ").strip()

        if wybor == '1':
            wyczysc_ekran()
            szukaj_psa(baza_psow)
        elif wybor == '2':
            wyczysc_ekran()
            pokaz_wszystkie(baza_psow)
        elif wybor == '3':
            print("\nDo zobaczenia! Hau hau!")
            break
        else:
            print("\n[!] Niepoprawny wybór.")
            input("Wciśnij ENTER i spróbuj ponownie...")

if __name__ == "__main__":
    main()