
# 📱 Pochodzenie ma znaczenie

Aplikacja mobilna Flutter do sprawdzania kraju pochodzenia produktów na podstawie kodu kreskowego.  
Projekt na wczesnym etapie — MVP, 100% open-source.

## ✨ Funkcje

- ✅ Logowanie użytkownika (token JWT)
- ✅ Skanowanie kodów kreskowych (kamera)
- ✅ Pobieranie informacji o produkcie (nazwa, marka, kraj)
- ✅ Wyróżnianie produktów pochodzących z USA
- ✅ Tryb testowy bez skanera

## 🛠️ Stack technologiczny

- Flutter 3.x
- Dart
- Biblioteka [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)
- Backend REST API (Spring Boot, endpointy `/api/login` i `/api/barcodeinfo`)

## 🔧 Struktura aplikacji

| Ekran               | Klasa                |
|---------------------|----------------------|
| Ekran logowania     | `LoginScreen`        |
| Skaner kodów        | `ScannerScreen`      |
| Szczegóły produktu  | `ProductScreen`      |
| Główna konfiguracja | `MyApp` (`main.dart`) |

## 🗺️ Flow aplikacji

1. Użytkownik loguje się do systemu → otrzymuje token JWT
2. Trafia na ekran skanera
3. Skanuje kod kreskowy produktu
4. Aplikacja pobiera dane z backendu `/api/barcodeinfo`
5. Wyświetla szczegóły produktu  
   (jeżeli kraj = USA → wyświetla ostrzeżenie)

## 🔑 Logowanie

Backend wymaga autoryzacji — token JWT jest pobierany po poprawnym logowaniu:

```http
POST /api/login
Content-Type: application/json

{
  "playerName": "nazwa_uzytkownika",
  "password": "haslo"
}
```

Token jest automatycznie przekazywany w nagłówku do dalszych requestów:

```http
Authorization: Bearer <TOKEN>
```

## 🚀 Uruchomienie lokalne

1. Skopiuj repozytorium:

    ```bash
    git clone https://github.com/TwojeRepozytorium/pochodzenie-ma-znaczenie.git
    cd pochodzenie-ma-znaczenie
    ```

2. Zainstaluj zależności:

    ```bash
    flutter pub get
    ```

3. Uruchom:

    ```bash
    flutter run
    ```

> Wymagane: urządzenie fizyczne lub emulator z dostępem do kamery.

## 📂 TODO / Roadmap

- [ ] Rejestracja nowego użytkownika
- [ ] Ekran ustawień
- [ ] Historia skanów
- [ ] Obsługa offline / cache
- [ ] Konfiguracja własnego backendu (adres API z poziomu ustawień)

## 📝 Licencja

MIT — używaj dowolnie.

---

