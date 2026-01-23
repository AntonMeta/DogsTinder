# 🐶 Tinder dla Psów (DogsTinder)

Aplikacja typu "Tinder" dla psów do adopcji. Pozwala przeglądać karty psów, filtrować je po cechach i dodawać do ulubionych.

## 🛠️ Tech Stack

Projekt jest w pełni skonteneryzowany i składa się z trzech głównych modułów:

- **Frontend:** Flutter (Web)
- **Backend:** Python (FastAPI + SQLAlchemy)
- **Baza Danych:** PostgreSQL
- **Infrastruktura:** Docker & Docker Compose

## 🚀 Instalacja i Konfiguracja

### 1. Wymagania wstępne

- **Docker**
- **Git**

### 2. Konfiguracja Zmiennych (.env)

Ze względów bezpieczeństwa plik z hasłami nie znajduje się w repozytorium. Musisz utworzyć go ręcznie.

1.  W **głównym folderze projektu** (tam gdzie `docker-compose.yaml`) utwórz plik o nazwie `.env`.
2.  Wklej do niego poniższą konfigurację:

```ini
# Konfiguracja PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=twojetajnehaslo
POSTGRES_DB=dogstinder

# Adres bazy danych dla Backend'u (wewnątrz sieci Docker)
# Zwróć uwagę na hosta '@db' - to nazwa serwisu w docker-compose
DATABASE_URL=postgresql://postgres:twojetajnehaslo@db:5432/dogstinder
```

## ▶️ Uruchamianie Aplikacji

Aby uruchomić projekt, wpisz w terminalu (będąc w głównym folderze):

```bash
docker-compose up --build
```

_Uwaga: Pierwsze uruchomienie zajmie chwilę, ponieważ Docker musi pobrać obrazy dla Fluttera i Pythona._

Gdy terminal przestanie wyświetlać nowe logi, aplikacja jest dostępna pod adresami:

- 🐶 **Frontend (Aplikacja):** [http://localhost:3000](http://localhost:3000)
- ⚙️ **Backend (Dokumentacja API):** [http://localhost:8000/docs](http://localhost:8000/docs)

## 🌱 Wgrywanie Przykładowych Danych

Po pierwszym uruchomieniu na nowym dysku baza danych będzie pusta. Aby wypełnić ją psami z pliku `psy.txt` (lub domyślnymi danymi), wykonaj następujące kroki:

1.  Upewnij się, że kontenery działają (nie zamykaj głównego terminala).
2.  Otwórz **nowe okno terminala**.
3.  Wpisz komendę:

```bash
docker-compose exec api python seed.py
```

Jeśli zobaczysz komunikat `Sukces! Psy są w bazie PostgreSQL.`, możesz odświeżyć stronę w przeglądarce.

## 📂 Struktura Projektu

- `backend/` - Kod API (FastAPI) i modele bazy danych.
- `frontend/` - Kod aplikacji mobilnej/webowej (Flutter).
- `docker-compose.yaml` - Definicja całej infrastruktury.
