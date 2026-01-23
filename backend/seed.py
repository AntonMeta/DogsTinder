from database import SessionLocal, engine, Base
from models import PiesDB
import os

Base.metadata.create_all(bind=engine)


def importuj_psy():
    db = SessionLocal()

    if db.query(PiesDB).count() > 0:
        print("Baza już zawiera dane. Pomijam import.")
        return

    if not os.path.exists("psy.csv"):
        print("Brak pliku psy.txt!")
        return

    print("Importowanie danych z psy.txt...")

    with open("psy.csv", "r", encoding="utf-8") as f:
        for linia in f:
            dane = linia.strip().split(',')
            if len(dane) >= 5:
                pies = PiesDB(
                    imie=dane[0].strip(),
                    rasa=dane[1].strip(),
                    wiek=int(dane[2].strip()),
                    plec=dane[3].strip(),
                    kolor=dane[4].strip(),
                    opis="Przykładowy opis psa...",
                    zdjecie_url="https://placedog.net/500/500"
                )
                db.add(pies)

    db.commit()
    print("Sukces! Psy są w bazie PostgreSQL.")
    db.close()


if __name__ == "__main__":
    importuj_psy()
