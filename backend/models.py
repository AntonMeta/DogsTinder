from sqlalchemy import Column, Integer, String
from database import Base


class PiesDB(Base):
    __tablename__ = "psy"

    id = Column(Integer, primary_key=True, index=True)
    imie = Column(String, index=True)
    rasa = Column(String)
    wiek = Column(Integer)
    plec = Column(String)
    kolor = Column(String)
    opis = Column(String, nullable=True)
    zdjecie_url = Column(String, nullable=True)
