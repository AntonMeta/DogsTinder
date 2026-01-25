from database import SessionLocal, engine, Base
from models import PiesDB
import os

Base.metadata.create_all(bind=engine)


BASE_IMAGE_URL = "https://res.cloudinary.com/de7ozj4o0/image/upload/v1769370378/"


def importuj_psy():
    db = SessionLocal()

    if db.query(PiesDB).count() > 0:
        print("Baza nie jest pusta. Pomijam import.")
        db.close()
        return

    if not os.path.exists("psy.csv"):
        print("Brak pliku psy.csv!")
        db.close()
        return

    print(f"Importowanie psów i łączenie ze zdjęciami z: {BASE_IMAGE_URL} ...")

    try:
        with open("psy.csv", "r", encoding="utf-8") as f:
            for linia in f:
                dane = linia.strip().split(',')

                if len(dane) >= 6:
                    pies = PiesDB(
                        imie=dane[0].strip(),
                        rasa=dane[1].strip(),
                        wiek=int(dane[2].strip()),
                        plec=dane[3].strip(),
                        kolor=dane[4].strip(),
                        opis=dane[5].strip(),
                        zdjecie_url=""
                    )
                    db.add(pies)

                    db.flush()

                    pies.zdjecie_url = f"{BASE_IMAGE_URL}{pies.id}.jpg"

        db.commit()
        print("Sukces! Psy zaimportowane, linki do zdjęć wygenerowane.")

    except Exception as e:
        print(f"Wystąpił błąd: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    importuj_psy()
