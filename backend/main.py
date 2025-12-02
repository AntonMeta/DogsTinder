from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os

app = FastAPI()

# potrzebne do obejscia CORS'a (przy testach na chromie)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# klasa psa


class PiesData(BaseModel):
    imie: str
    rasa: str
    wiek: int
    plec: str
    kolor: str

# wczytywanie bazy z pliku


def wczytaj_psy():
    sciezka = "psy.csv"
    psy = []
    if os.path.exists(sciezka):
        with open(sciezka, 'r', encoding='utf-8') as f:
            for linia in f:
                dane = linia.strip().split(',')
                if len(dane) == 5:
                    psy.append({
                        "imie": dane[0],
                        "rasa": dane[1],
                        "wiek": int(dane[2]),
                        "plec": dane[3],
                        "kolor": dane[4]
                    })
    return psy

# endpoint: daj wszystkie psy


@app.get("/psy")
def pobierz_psy():
    return wczytaj_psy()

# endpoint:filtrowanie


@app.get("/szukaj")
def szukaj_psow(wiek: int = 100, plec: str = "", kolor: str = ""):
    wszystkie = wczytaj_psy()
    znalezione = []

    for pies in wszystkie:
        zgodnosc_plec = (plec == "" or pies['plec'].lower() == plec.lower())
        zgodnosc_kolor = (
            kolor == "" or pies['kolor'].lower() == kolor.lower())
        zgodnosc_wiek = (pies['wiek'] <= wiek)

        if zgodnosc_plec and zgodnosc_kolor and zgodnosc_wiek:
            znalezione.append(pies)

    return znalezione


@app.get("/kolory")
def pobierz_dostepne_kolory():
    wszystkie_psy = wczytaj_psy()
    unikalne_kolory = {p['kolor'] for p in wszystkie_psy}
    return sorted(list(unikalne_kolory))
