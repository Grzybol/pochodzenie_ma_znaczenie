# Dokumentacja projektu: Pochodzenie Ma Znaczenie

## Cel projektu
Aplikacja mobilna umożliwiająca użytkownikom sprawdzanie kraju pochodzenia produktów na podstawie kodu kreskowego. Projekt wspiera świadome wybory konsumenckie poprzez szybki dostęp do informacji o produktach. Aplikacja została przygotowana jako zaliczenie przedmiotu na studiach.

## Funkcjonalności
- Logowanie użytkownika z wykorzystaniem JWT
- Skanowanie kodów kreskowych za pomocą kamery
- Pobieranie i wyświetlanie szczegółowych informacji o produkcie (nazwa, marka, kraj pochodzenia)
- Wyróżnianie produktów pochodzących z USA
- Tryb testowy (ręczne wpisanie kodu bez użycia kamery)
- Lokalny cache danych produktów z konfigurowalnym czasem życia (TTL)
- Panel ustawień: zmiana TTL cache, czyszczenie cache, informacja o liczbie produktów w cache
- Automatyczne odświeżanie tokena JWT po wygaśnięciu (endpoint /renew)

## Architektura i przepływ aplikacji
1. Użytkownik loguje się do systemu (token JWT)
2. Przechodzi na ekran skanera
3. Skanuje kod kreskowy produktu lub korzysta z trybu testowego
4. Aplikacja sprawdza lokalny cache:
   - Jeśli dane są obecne i ważne (nieprzeterminowane), wyświetla je
   - Jeśli nie, pobiera dane z backendu i zapisuje w cache
5. Wyświetlane są szczegóły produktu (jeśli kraj = USA, pojawia się ostrzeżenie)
6. Użytkownik może zarządzać cache z poziomu panelu ustawień
7. Token JWT jest automatycznie odświeżany po wygaśnięciu (jeśli odświeżenie się nie powiedzie, następuje wylogowanie)

## Stos technologiczny
- Flutter 3.x (Dart)
- mobile_scanner (skanowanie kodów)
- shared_preferences (lokalny cache)
- REST API (Spring Boot, endpointy: /api/login, /api/barcodeinfo, /api/renew)

## Struktura katalogów
- `lib/` – główny kod aplikacji Flutter (ekrany, logika, utils)
- `assets/` – zasoby graficzne (ikony)
- `android/`, `ios/`, `macos/`, `linux/`, `windows/` – pliki natywne dla poszczególnych platform
- `test/` – testy jednostkowe (przykładowe)
- `docs/` – dokumentacja projektu

## Główne pliki Dart
- `main.dart` – punkt wejścia aplikacji, konfiguracja tras i motywu
- `login_screen.dart` – ekran logowania, obsługa JWT
- `scanner_screen.dart` – ekran skanera, obsługa kamery, panel ustawień
- `product_screen.dart` – ekran szczegółów produktu, obsługa cache
- `utils.dart` – funkcje pomocnicze (notyfikacje, cache, JWT)

## Logika cache i JWT
- Dane produktów są cache'owane lokalnie (shared_preferences) z TTL ustawianym przez użytkownika
- Panel ustawień umożliwia zmianę TTL, czyszczenie cache oraz podgląd liczby produktów w cache
- Token JWT jest automatycznie odświeżany po wygaśnięciu (endpoint /renew). W przypadku niepowodzenia użytkownik zostaje wylogowany

## Uruchamianie projektu
1. Zainstaluj Flutter SDK
2. Pobierz zależności: `flutter pub get`
3. Uruchom aplikację: `flutter run` (wymagane urządzenie fizyczne lub emulator z kamerą)

## Konto testowe
Login: test3  
Hasło: asd123!

## Kontakt
W przypadku pytań lub sugestii prosimy o kontakt z zespołem deweloperskim. 