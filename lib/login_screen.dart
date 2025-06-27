import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Auth {
  static String? token; //token
  static String? playerName; //nazwa gracza

  static Future<void> setToken(String newToken, String user) async {
    print('[Auth] setToken: token=$newToken, playerName=$user'); //logowanie
    token = newToken; //zapisanie tokenu
    playerName = user; //zapisanie nazwy gracza
    final prefs = await SharedPreferences.getInstance(); //pobranie danych z prefs
    await prefs.setString('jwt_token', newToken); //zapisanie tokenu
    await prefs.setString('player_name', user); //zapisanie nazwy gracza
  }

  static Future<void> loadFromPrefs() async {
    print('[Auth] loadFromPrefs: loading...'); //logowanie
    final prefs = await SharedPreferences.getInstance(); //pobranie danych z prefs
    token = prefs.getString('jwt_token'); //pobranie tokenu
    playerName = prefs.getString('player_name'); //pobranie nazwy gracza
    print('[Auth] loadFromPrefs: token=$token, playerName=$playerName'); //logowanie
  }

  static Map<String, String> getAuthHeaders() {
    return { //zwracanie nagłówków autoryzacji
      'Authorization': 'Bearer $token', //token
      'Content-Type': 'application/json', //typ zawartości
    };
  }

  static Future<void> logout() async {
    token = null; //usunięcie tokenu
    playerName = null; //usunięcie nazwy gracza
    final prefs = await SharedPreferences.getInstance(); //pobranie danych z prefs
    await prefs.remove('jwt_token'); //usunięcie tokenu
    await prefs.remove('player_name'); //usunięcie nazwy gracza
  }

  static Future<bool> refreshToken() async {
    const baseUrl = 'https://boxpvp.top:8443/api'; //URL API
    print('[Auth] refreshToken: token=$token, playerName=$playerName'); //logowanie
    try { //pobranie danych z API
      final response = await http.post( //pobranie danych z API
        Uri.parse('$baseUrl/renew'),
        headers: getAuthHeaders(), //nagłówki autoryzacji
      );
      print('[Auth] refreshToken: response.statusCode=${response.statusCode}'); //logowanie
      if (response.statusCode == 200) { //jeśli odpowiedź jest 200
        final data = json.decode(response.body); //pobranie danych z API
        await setToken(data['token'], playerName!); //zapisanie tokenu
        print('[Auth] Token refreshed successfully'); //logowanie
        return true;
      } else {
        print('[Auth] Failed to refresh token: ${response.statusCode}'); //logowanie
        await logout(); //wylogowanie
        return false;
      }
    } catch (e) {
      print('[Auth] Error refreshing token: $e'); //logowanie
      return false; //zwracanie false
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState(); //utworzenie stanu
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(); //kontroler nazwy gracza
  final _passwordController = TextEditingController(); //kontroler hasła
  String? _error; //błąd
  bool _isLoading = false; //czy jest ładowanie

  Future<void> _login() async {
    final username = _usernameController.text.trim(); //pobranie nazwy gracza
    final password = _passwordController.text.trim(); //pobranie hasła

    if (username.isEmpty || password.isEmpty) { //jeśli nazwa gracza lub hasło jest puste
      setState(() => _error = "Podaj login i hasło."); //zapisanie błędu
      return; //zakończenie funkcji
    }

    setState(() { //zaktualizowanie stanu
      _isLoading = true; //zapisanie ładowania
      _error = null; //usunięcie błędu
    }); //zaktualizowanie stanu

    try { //pobranie danych z API
      final response = await http.post( //pobranie danych z API
        Uri.parse('https://boxpvp.top:8443/api/login'), //URL API
        headers: { 'Content-Type': 'application/json' }, //nagłówki autoryzacji
        body: json.encode({ 'playerName': username, 'password': password }), //treść
      );

      if (response.statusCode == 200) { //jeśli odpowiedź jest 200
        final data = json.decode(response.body); //pobranie danych z API
        await Auth.setToken(data['token'], username); //zapisanie tokenu
        // przejście do skanera
        Navigator.pushReplacementNamed(context, '/scanner'); //przejście do skanera
      } else {
        setState(() => _error = "Nieprawidłowy login lub hasło."); //zapisanie błędu
      }
    } catch (e) {
      setState(() => _error = "Błąd połączenia z serwerem."); //zapisanie błędu
    } finally {
      setState(() => _isLoading = false); //zapisanie ładowania
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //ekran
      body: Stack( //stos elementów
        children: [ //elementy
          // Blur kamera na tło
          Opacity( //przezroczystość
            opacity: 0.5, //przezroczystość
            child: Image.asset( //obraz
              'assets/icon1.png',  // lub inny obrazek tła (kamera dopiszemy potem)
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center( //wyśrodkowanie
            child: Padding( //padding
              padding: const EdgeInsets.all(24), //padding
              child: Card( //kartka
                elevation: 8, //rzucenie cienia
                shape: RoundedRectangleBorder( //krawędzie zaokrąglone
                  borderRadius: BorderRadius.circular(16), //zaokrąglenie krawędzi
                ),
                child: Padding( //padding
                  padding: const EdgeInsets.all(24), //padding
                  child: Column( //kolumna
                    mainAxisSize: MainAxisSize.min,
                    children: [ //elementy
                      const Text( //tekst
                        "🔐 Logowanie", //tekst
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), //styling tekstu
                      ),
                      const SizedBox(height: 16), //odstęp
                      TextField( //pole tekstowe
                        controller: _usernameController, //kontroler nazwy gracza
                        decoration: const InputDecoration(labelText: "Nazwa gracza"), //dekoracja
                      ),
                      const SizedBox(height: 12), //odstęp
                      TextField( //pole tekstowe
                        controller: _passwordController, //kontroler hasła
                        decoration: const InputDecoration(labelText: "Hasło"), //dekoracja
                        obscureText: true, //ukrywanie tekstu
                      ),
                      const SizedBox(height: 16), //odstęp
                      if (_error != null) //jeśli jest błąd
                        Text( //tekst
                          _error!,
                          style: const TextStyle(color: Colors.red), //styling tekstu
                        ),
                      const SizedBox(height: 16), //odstęp
                      ElevatedButton( //przycisk
                        onPressed: _isLoading ? null : _login, //funkcja logowania
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) //pasek ładowania
                            : const Text("Zaloguj"), //tekst
                      ),
                    ], //elementy
                  ), //kolumna
                ), //padding
              ), //kartka
            ), //padding
          ), //wyśrodkowanie
        ], //elementy
      ), //stos elementów
    ); //ekran
  }
}
