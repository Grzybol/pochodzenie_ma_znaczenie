# Pochodzenie Ma Znaczenie

Aplikacja mobilna Flutter do sprawdzania kraju pochodzenia produktów na podstawie kodu kreskowego. Projekt jest open-source i znajduje się na etapie MVP.

## Funkcjonalności

- Logowanie użytkownika z użyciem JWT (wymagane do korzystania z aplikacji)
- Skanowanie kodów kreskowych za pomocą kamery urządzenia
- Pobieranie informacji o produkcie (nazwa, marka, kraj) z backendu REST API
- Wyróżnianie produktów pochodzących z USA
- Tryb testowy (ręczne wpisanie kodu bez użycia kamery)
- Lokalny cache danych produktów z konfigurowalnym czasem życia (TTL)
- Panel ustawień w aplikacji do zarządzania cache (zmiana TTL, czyszczenie cache, informacja o liczbie produktów w cache)
- Automatyczne odświeżanie tokena JWT po wygaśnięciu (wykorzystanie endpointu /renew)

## Stos technologiczny

- Flutter 3.x
- Dart
- Biblioteka [mobile_scanner](https://pub.dev/packages/mobile_scanner)
- Backend REST API (Spring Boot, endpointy: /api/login, /api/barcodeinfo, /api/renew)
- Lokalna pamięć: shared_preferences

## Struktura aplikacji

| Ekran              | Klasa             |
|--------------------|------------------|
| Logowanie          | LoginScreen       |
| Skaner kodów       | ScannerScreen     |
| Szczegóły produktu | ProductScreen     |
| Konfiguracja główna| MyApp (main.dart) |

## Przepływ aplikacji

1. Użytkownik loguje się i otrzymuje token JWT
2. Przechodzi na ekran skanera
3. Skanuje kod kreskowy produktu
4. Aplikacja sprawdza lokalny cache:
   - Jeśli dane są obecne i ważne (nieprzeterminowane), używa cache
   - Jeśli nie ma danych lub są przeterminowane, pobiera z backendu (/api/barcodeinfo)
5. Wyświetlane są szczegóły produktu
   - Jeśli kraj to USA, pojawia się ostrzeżenie

## Autoryzacja i zarządzanie tokenem

- Backend wymaga autoryzacji JWT. Token uzyskiwany jest po poprawnym logowaniu:

      POST /api/login
      Content-Type: application/json

      {
        "playerName": "nazwa_uzytkownika",
        "password": "haslo"
      }

- Token przekazywany jest w nagłówku Authorization przy wszystkich kolejnych żądaniach:

      Authorization: Bearer <TOKEN>

- Aplikacja automatycznie odświeża token JWT po jego wygaśnięciu (endpoint /api/renew). W przypadku niepowodzenia użytkownik zostaje wylogowany.

## Lokalny cache

- Dane produktów są cache'owane lokalnie przy użyciu shared_preferences
- Czas życia cache (TTL, w godzinach) można ustawić w panelu ustawień aplikacji
- Panel ustawień pozwala na:
  - Zmianę TTL cache (liczba całkowita, godziny)
  - Wyczyść lokalny cache
  - Sprawdzenie liczby produktów w cache
- Jeśli produkt znajduje się w cache i nie jest przeterminowany, aplikacja nie wykonuje zapytania do backendu

## Uruchomienie lokalne

1. Sklonuj repozytorium:

       git clone https://github.com/TwojeRepozytorium/pochodzenie-ma-znaczenie.git
       cd pochodzenie-ma-znaczenie

2. Zainstaluj zależności:

       flutter pub get

3. Uruchom aplikację:

       flutter run

   Wymagane jest urządzenie fizyczne lub emulator z dostępem do kamery.

## Roadmap

- Rejestracja użytkownika
- Rozbudowany ekran ustawień
- Historia skanów
- Obsługa offline / ulepszenia cache
- Możliwość konfiguracji własnego backendu (adres API w ustawieniach)

## Licencja

MIT License


---

