from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import or_

from database import get_db, Base, engine
import models

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/kolory")
def pobierz_kolory(db: Session = Depends(get_db)):
    kolory = db.query(models.PiesDB.kolor).distinct().order_by(
        models.PiesDB.kolor).all()
    return [k[0] for k in kolory]


@app.get("/szukaj")
def szukaj_psow(
    wiek: int,
    plec: str,
    kolor: str,
    db: Session = Depends(get_db)
):
    query = db.query(models.PiesDB)

    query = query.filter(models.PiesDB.wiek <= wiek)
    if plec and plec.lower() != "":
        query = query.filter(models.PiesDB.plec == plec)
    if kolor and kolor.lower() != "":
        query = query.filter(models.PiesDB.kolor == kolor)

    psy = query.all()

    return psy



# @app.post("/dodaj")
# def dodaj_psa(imie: str, rasa: str, wiek: int, plec: str, kolor: str, db: Session = Depends(get_db)):
#     nowy_pies = models.PiesDB(imie=imie, rasa=rasa,
#                               wiek=wiek, plec=plec, kolor=kolor)
#     db.add(nowy_pies)
#     db.commit()
#     return {"message": "Pies dodany!"}
