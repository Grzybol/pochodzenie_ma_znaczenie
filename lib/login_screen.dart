import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Auth {
  static String? token;
  static String? playerName;

  static Future<void> setToken(String newToken, String user) async {
    print('[Auth] setToken: token=$newToken, playerName=$user');
    token = newToken;
    playerName = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', newToken);
    await prefs.setString('player_name', user);
  }

  static Future<void> loadFromPrefs() async {
    print('[Auth] loadFromPrefs: loading...');
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');
    playerName = prefs.getString('player_name');
    print('[Auth] loadFromPrefs: token=$token, playerName=$playerName');
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<void> logout() async {
    token = null;
    playerName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('player_name');
  }

  static Future<bool> refreshToken() async {
    const baseUrl = 'https://boxpvp.top:8443/api';
    print('[Auth] refreshToken: token=$token, playerName=$playerName');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/renew'),
        headers: getAuthHeaders(),
      );
      print('[Auth] refreshToken: response.statusCode=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await setToken(data['token'], playerName!);
        print('[Auth] Token refreshed successfully');
        return true;
      } else {
        print('[Auth] Failed to refresh token: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e) {
      print('[Auth] Error refreshing token: $e');
      return false;
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = "Podaj login i hasło.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://boxpvp.top:8443/api/login'),
        headers: { 'Content-Type': 'application/json' },
        body: json.encode({ 'playerName': username, 'password': password }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await Auth.setToken(data['token'], username);
        // przejście do skanera
        Navigator.pushReplacementNamed(context, '/scanner');
      } else {
        setState(() => _error = "Nieprawidłowy login lub hasło.");
      }
    } catch (e) {
      setState(() => _error = "Błąd połączenia z serwerem.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blur kamera na tło
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/icon1.png',  // lub inny obrazek tła (kamera dopiszemy potem)
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "🔐 Logowanie",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: "Nazwa gracza"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: "Hasło"),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Zaloguj"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
